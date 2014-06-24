#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <string.h>
#include "webimg/webimg2.h"
#include "zlog.h"
#include "zcommon.h"
#include "zscale.h"

static int proportion(struct image *im, uint32_t arg_cols, uint32_t arg_rows);
int convert(struct image *im, zimg_req_t *req);


/*
 * 
 * sample URLs:
 * http://127.0.0.1:4869/md5?w=300
 * http://127.0.0.1:4869/md5?w=200&h=300
 * http://127.0.0.1:4869/md5?t=square
 * http://127.0.0.1:4869/md5?t=square&s=200
 * http://127.0.0.1:4869/md5?t=crop&x=0&y=0&w=100&h=100
 * http://127.0.0.1:4869/md5?t=maxwidth
 * http://127.0.0.1:4869/md5?t=maxsize
 *
 *
 *
 */

static int square(struct image *im, uint32_t size)
{
	int ret;
	uint32_t x, y, cols;

	if (im->cols > im->rows) {
		cols = im->rows;
		y = 0;
		x = (uint32_t)floor((im->cols - im->rows) / 2.0);
	} else {
		cols = im->cols;
		x = 0;
		y = (uint32_t)floor((im->rows - im->cols) / 2.0);
	}

	ret = wi_crop(im, x, y, cols, cols);
	if (ret != WI_OK) return -1;

	ret = wi_scale(im, size, 0);
	if (ret != WI_OK) return -1;

	return 0;
}

static int proportion(struct image *im, uint32_t arg_cols, uint32_t arg_rows)
{
	int ret;
    uint32_t cols, rows;

    if (arg_cols == 0 && arg_rows == 0) return 0;

    if (arg_cols != 0)
    {
        cols = arg_cols;
        if (im->cols < cols) return 1;
        rows = 0;
    }
    else
    {
        rows = arg_rows;
        if (im->rows < rows) return 1;
        cols = 0;
    }

    LOG_PRINT(LOG_INFO, "wi_scale(im, %d, %d)", cols, rows);
	ret = wi_scale(im, cols, rows);
	return (ret == WI_OK) ? 0 : -1;
}

int convert(struct image *im, zimg_req_t *req)
{
    int result;
	int ret;

    LOG_PRINT(LOG_DEBUG, "proportion(im, %d, %d)", req->width, req->height);
    result = proportion(im, req->width, req->height);
    //result = 1;
	if (result == -1) return -1;

    /* set gray */
    if (req->gray && im->colorspace != CS_GRAYSCALE) {
        LOG_PRINT(LOG_DEBUG, "wi_gray(im)");
        result = wi_gray(im);
        if (result == -1) return -1;
    }

	/* set quality */
	if (im->quality > WAP_QUALITY) {
        LOG_PRINT(LOG_DEBUG, "wi_set_quality(im, %d)", WAP_QUALITY);
		wi_set_quality(im, WAP_QUALITY);
	}

	/* set format */
	if (strncmp(im->format, "GIF", 3) != 0) {
        LOG_PRINT(LOG_DEBUG, "wi_set_format(im, %s)", "JPEG");
        ret = wi_set_format(im, "JPEG");
        if (ret != WI_OK) return -1;
	}

    LOG_PRINT(LOG_DEBUG, "convert(im, req) %d", result);
	return result;
}

