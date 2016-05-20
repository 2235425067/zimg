package server

import (
	"fmt"
	"log"
	"math"

	"github.com/buaazp/zimg/common"
	"gopkg.in/gographics/imagick.v2/imagick"
)

var (
	DefaultOutputFormat       string  = "JPEG"
	DefaultCompressionQuality uint    = 75
	LongImageSideRatio        float64 = 2.5
	LongImageSideRatioInverse float64 = 1 / LongImageSideRatio
)

func outOfImage(cols, rows, x, y uint) bool {
	return x > cols || y > rows
}

func Convert(blob []byte, cp *common.ConvertParam) (string, []byte, error, int) {
	im := imagick.NewMagickWand()
	defer im.Destroy()

	err := im.ReadImageBlob(blob)
	if err != nil {
		return "", nil, err, 400
	}

	format := im.GetImageFormat()
	// log.Printf("orgin fomart %s", format)
	switch format {
	case "GIF":
		// GIF special processing section
		if cp.Format == "" || cp.Format == "GIF" {
			return format, blob, nil, 200
		}
		// Composites a set of images while respecting any page
		// offsets and disposal methods
		gifim := im.CoalesceImages()
		defer gifim.Destroy()
		im = gifim
	case "PNG":
		// PNG special processing section
		// convert transparent to white background
		background := imagick.NewPixelWand()
		defer background.Destroy()
		if succ := background.SetColor("white"); !succ {
			log.Printf("[warn] %s png set color white err", cp.Key)
		} else {
			if err := im.SetImageBackgroundColor(background); err != nil {
				log.Printf("[warn] %s png set background color err: %s", cp.Key, err)
			} else {
				pngim := im.MergeImageLayers(imagick.IMAGE_LAYER_FLATTEN)
				defer pngim.Destroy()
				im = pngim
			}
		}
	default:
	}

	if cp.FormatOnly {
		if cp.Format == format {
			return format, blob, nil, 200
		}
	} else {
		if err := im.AutoOrientImage(); err != nil {
			log.Printf("[warn] %s auto orient err: %s", cp.Key, err)
		}

		var code int
		switch cp.Mode {
		case common.ModeFill:
			err, code = FiConvertFill(im, cp)
		case common.ModeFit:
			err, code = FiConvertFit(im, cp)
		case common.ModeStretch:
			err, code = FiConvertStretch(im, cp)
		default:
			return "", nil, fmt.Errorf("unknown convert mode: %+v", cp.Mode), 400
		}
		if err != nil {
			return "", nil, err, code
		}
	}

	if cp.Format != "" {
		err = im.SetImageFormat(cp.Format)
		if err != nil {
			return "", nil, err, 500
		}
	}

	quality := im.GetImageCompressionQuality()
	if quality > DefaultCompressionQuality || quality == 0 {
		if err := im.SetImageCompressionQuality(DefaultCompressionQuality); err != nil {
			log.Printf("[warn] %s set quality %d err: %s", cp.Key, DefaultCompressionQuality, err)
		}
	}

	newFormat := im.GetImageFormat()
	body := im.GetImageBlob()
	return newFormat, body, nil, 200
}

func cropPostion(im *imagick.MagickWand, cp *common.ConvertParam) (x, y, w, h uint, err error, code int) {
	imCols := im.GetImageWidth()
	imRows := im.GetImageHeight()

	x = uint(float64(imCols) * cp.RelativeX)
	y = uint(float64(imRows) * cp.RelativeY)
	if outOfImage(imCols, imRows, x, y) {
		err = fmt.Errorf("point1 [%d,%d] is out of image(%d, %d)", x, y, imCols, imRows)
		code = 400
		return
	}
	w = uint(float64(imCols) * cp.RelativeW)
	h = uint(float64(imRows) * cp.RelativeH)
	if x+w > imCols {
		log.Printf("warning: point2 [%d,%d] is out of image(%d, %d)", x+w, y+h, imCols, imRows)
		w = imCols - x
	}
	if y+h > imRows {
		log.Printf("warning: point2 [%d,%d] is out of image(%d, %d)", x+w, y+h, imCols, imRows)
		h = imRows - y
	}
	code = 200
	return
}

func fiJustCrop(im *imagick.MagickWand, cp *common.ConvertParam) (error, int) {
	// log.Printf("just croping...")
	x, y, w, h, err, code := cropPostion(im, cp)
	if err != nil {
		return err, code
	}

	err = im.CropImage(w, h, int(x), int(y))
	if err != nil {
		return err, 500
	}
	return nil, 200
}

func FiConvertFill(im *imagick.MagickWand, cp *common.ConvertParam) (error, int) {
	if cp.NeedCrop() {
		if cp.Width == 0 && cp.Height == 0 {
			return fiJustCrop(im, cp)
		} else {
			return fiCropAndFillResize(im, cp)
		}
	}

	return fiFillResize(im, cp)
}

func fiFillCrop(im *imagick.MagickWand, imCols, imRows, x, y uint, cp *common.ConvertParam) (error, int) {
	// log.Printf("fill croping...")
	if cp.Width == 0 && cp.Height == 0 {
		return fmt.Errorf("both width and height are not set"), 400
	}

	if cp.Width != 0 && cp.Height != 0 {
		xf := float64(cp.Width) / float64(imCols)
		yf := float64(cp.Height) / float64(imRows)

		var cols, rows uint
		if xf > yf {
			cols = imCols
			rows = uint(math.Floor(float64(cp.Height) / xf))
			if rows == 0 {
				rows = 1
			}
		} else if yf > xf {
			cols = uint(math.Floor(float64(cp.Width) / yf))
			if cols == 0 {
				cols = 1
			}
			rows = imRows
		} else if cp.NeedCrop() {
			cols = imCols
			rows = imRows
		} else {
			return nil, 200
		}

		imRatio := float64(imCols) / float64(imRows)
		if imRatio > LongImageSideRatio || imRatio < LongImageSideRatioInverse {
			// crop a long image use gravity north-west
			cp.Gravity = common.NorthWest
		}

		switch cp.Gravity {
		case common.Center:
			x += (imCols - cols) / 2
			y += (imRows - rows) / 2
		case common.North:
			x += (imCols - cols) / 2
			y += 0
		case common.South:
			x += (imCols - cols) / 2
			y += imRows - rows
		case common.West:
			x += 0
			y += (imRows - rows) / 2
		case common.East:
			x += imCols - cols
			y += (imRows - rows) / 2
		case common.NorthWest:
			x += 0
			y += 0
		case common.NorthEast:
			x += imCols - cols
			y += 0
		case common.SouthWest:
			x += 0
			y += imRows - rows
		case common.SouthEast:
			x += imCols - cols
			y += imRows - rows
		default:
			return fmt.Errorf("illegal gravity mode: %v", cp.Gravity), 400
		}

		// log.Printf("crop: %d %d %d %d", x, y, cols, rows)
		err := im.CropImage(cols, rows, int(x), int(y))
		if err != nil {
			return err, 500
		}
	}

	return nil, 200
}

func fiCropAndFillResize(im *imagick.MagickWand, cp *common.ConvertParam) (error, int) {
	// log.Printf("fill crop and resizing...")
	x, y, w, h, err, code := cropPostion(im, cp)
	if err != nil {
		return err, code
	}

	err, code = fiFillCrop(im, w, h, x, y, cp)
	if err != nil {
		return err, code
	}

	imCols := im.GetImageWidth()
	imRows := im.GetImageHeight()
	if imCols > cp.Width || imRows > cp.Height {
		imRatio := float64(w) / float64(h)
		if cp.Width == 0 {
			cp.Width = uint(math.Floor(float64(cp.Height) * imRatio))
			if cp.Width == 0 {
				cp.Width = 1
			}
		}
		if cp.Height == 0 {
			cp.Height = uint(math.Floor(float64(cp.Width) / imRatio))
			if cp.Height == 0 {
				cp.Height = 1
			}
		}

		err = im.ResizeImage(cp.Width, cp.Height, imagick.FILTER_LANCZOS, 0.8)
		if err != nil {
			log.Printf("%s im.Resize(%d,%d)->(%d,%d) failed: %s", cp.Key, imCols, imRows, cp.Width, cp.Height, err)
			return err, 500
		}
	}

	return nil, 200
}

func fiFillResize(im *imagick.MagickWand, cp *common.ConvertParam) (error, int) {
	// log.Printf("fill resizing...")
	imCols := im.GetImageWidth()
	imRows := im.GetImageHeight()

	err, code := fiFillCrop(im, imCols, imRows, 0, 0, cp)
	if err != nil {
		return err, code
	}

	imCols = im.GetImageWidth()
	imRows = im.GetImageHeight()
	if imCols > cp.Width || imRows > cp.Height {
		imRatio := float64(imCols) / float64(imRows)
		if cp.Width == 0 {
			cp.Width = uint(math.Floor(float64(cp.Height) * imRatio))
			if cp.Width == 0 {
				cp.Width = 1
			}
		}
		if cp.Height == 0 {
			cp.Height = uint(math.Floor(float64(cp.Width) / imRatio))
			if cp.Height == 0 {
				cp.Height = 1
			}
		}

		err = im.ResizeImage(cp.Width, cp.Height, imagick.FILTER_LANCZOS, 0.8)
		if err != nil {
			log.Printf("%s im.Resize(%d,%d)->(%d,%d) failed: %s", cp.Key, imCols, imRows, cp.Width, cp.Height, err)
			return err, 500
		}
	}

	return nil, 200
}

func FiConvertFit(im *imagick.MagickWand, cp *common.ConvertParam) (error, int) {
	if cp.NeedCrop() {
		if cp.Width == 0 && cp.Height == 0 {
			return fiJustCrop(im, cp)
		} else {
			return fiCropAndFitResize(im, cp)
		}
	}

	return fiFitResize(im, cp)
}

func fiFitScale(im *imagick.MagickWand, imCols, imRows, x, y uint, cp *common.ConvertParam) (error, int) {
	// log.Printf("fit scaling...")
	if cp.Width == 0 {
		cp.Width = imCols
	}
	if cp.Height == 0 {
		cp.Height = imRows
	}

	xf := float64(cp.Width) / float64(imCols)
	yf := float64(cp.Height) / float64(imRows)

	var cols, rows uint
	if xf < yf {
		cols = cp.Width
		rows = uint(math.Floor(float64(imRows) * xf))
		if rows == 0 {
			rows = 1
		}
	} else if yf < xf {
		cols = uint(math.Floor(float64(imCols) * yf))
		if cols == 0 {
			cols = 1
		}
		rows = cp.Height
	} else {
		cols = cp.Width
		rows = cp.Height
	}

	if imCols > cols || imRows > rows {
		err := im.ResizeImage(cols, rows, imagick.FILTER_LANCZOS, 0.8)
		if err != nil {
			log.Printf("%s im.Resize(%d,%d)->(%d,%d) failed: %s", cp.Key, imCols, imRows, cols, rows, err)
			return err, 500
		}
	}

	return nil, 200
}

func fiCropAndFitResize(im *imagick.MagickWand, cp *common.ConvertParam) (error, int) {
	// log.Printf("fit crop and resizing...")
	x, y, w, h, err, code := cropPostion(im, cp)
	if err != nil {
		return err, code
	}

	err = im.CropImage(w, h, int(x), int(y))
	if err != nil {
		return err, 500
	}

	return fiFitScale(im, w, h, x, y, cp)
}

func fiFitSideScale(im *imagick.MagickWand, cp *common.ConvertParam) (error, int) {
	// log.Printf("fit side scaling...")
	imCols := im.GetImageWidth()
	imRows := im.GetImageHeight()

	cpCols := cp.LongSide
	cpRows := cp.ShortSide
	if imCols < imRows {
		cpCols = cp.ShortSide
		cpRows = cp.LongSide
	}
	xf := float64(cpCols) / float64(imCols)
	yf := float64(cpRows) / float64(imRows)
	if xf == 0 {
		xf = yf + 1
	} else if yf == 0 {
		yf = xf + 1
	}
	var cols, rows uint
	if xf < yf {
		cols = cpCols
		rows = uint(math.Floor(float64(imRows) * xf))
		if rows == 0 {
			rows = 1
		}
	} else if yf < xf {
		cols = uint(math.Floor(float64(imCols) * yf))
		if cols == 0 {
			cols = 1
		}
		rows = cpRows
	} else {
		cols = cpCols
		rows = cpRows
	}

	// log.Printf("cols: %d rows: %d", cols, rows)
	if imCols > cols || imRows > rows {
		err := im.ResizeImage(cols, rows, imagick.FILTER_LANCZOS, 0.8)
		if err != nil {
			log.Printf("%s im.Resize(%d,%d)->(%d,%d) failed: %s", cp.Key, imCols, imRows, cols, rows, err)
			return err, 500
		}
	}

	return nil, 200
}

func fiFitResize(im *imagick.MagickWand, cp *common.ConvertParam) (error, int) {
	// log.Printf("fit resizing...")
	if cp.LongSide > 0 || cp.ShortSide > 0 {
		return fiFitSideScale(im, cp)
	}

	if cp.Width == 0 && cp.Height == 0 {
		return fmt.Errorf("both width and height are not set"), 400
	}

	imCols := im.GetImageWidth()
	imRows := im.GetImageHeight()

	return fiFitScale(im, imCols, imRows, 0, 0, cp)
}

func FiConvertStretch(im *imagick.MagickWand, cp *common.ConvertParam) (error, int) {
	if cp.NeedCrop() {
		if cp.Width == 0 && cp.Height == 0 {
			return fiJustCrop(im, cp)
		} else {
			return fiCropAndStretchResize(im, cp)
		}
	}

	return fiStretchResize(im, cp)
}

func fiCropAndStretchResize(im *imagick.MagickWand, cp *common.ConvertParam) (error, int) {
	// log.Printf("stretch crop and resizing...")
	x, y, w, h, err, code := cropPostion(im, cp)
	if err != nil {
		return err, code
	}

	err = im.CropImage(w, h, int(x), int(y))
	if err != nil {
		return err, 500
	}

	return fiStretchResize(im, cp)
}

func fiStretchResize(im *imagick.MagickWand, cp *common.ConvertParam) (error, int) {
	// log.Printf("stretch resizing...")
	if cp.Width == 0 && cp.Height == 0 {
		return fmt.Errorf("both width and height are not set"), 400
	}

	err := im.ResizeImage(cp.Width, cp.Height, imagick.FILTER_LANCZOS, 0.8)
	if err != nil {
		return err, 500
	}

	return nil, 200
}
