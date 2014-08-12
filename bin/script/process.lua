local LOG_FATAL = 0
local LOG_ALERT = 1
local LOG_CRIT = 2
local LOG_ERROR = 3
local LOG_WARNING = 4
local LOG_NOTICE = 5
local LOG_INFO = 6
local LOG_DEBUG = 7

local TS_OK = 0
local TS_FAILED = -1

local WI_OK = 0
local WI_E_UNKNOW_FORMAT = 1
local WI_E_LOADER_INIT = 2
local WI_E_LOADER_LOAD = 3
local WI_E_READ_FILE = 4
local WI_E_WRITE_FILE = 5
local WI_E_ENCODE = 6

local CT_SQUARE = 0
local CT_MAX_WIDTH = 1
local CT_MAX_SIZE = 2
local CT_PROPORTION = 3
local CT_CROP = 4
local CT_NONE = 5

local CF_JPEG = 0
local CF_PNG = 1
local CF_GIF = 2
local CF_WEBP = 3

local WAP_QUALITY = 70
local TEST_QUALITY = 75
local THUMB_QUALITY = 85
local QUALITY_90 = 90
local QUALITY_95 = 95

local type_list = {
    woriginal = {
		type				= CT_NONE,
		quality			    = WAP_QUALITY,
    },
	mw2048 = {
		type				= CT_NONE,
		quality			    = WAP_QUALITY,
		interlace			= 1,
	},
	thumb30 = {
		type				= CT_SQUARE,
		size				= 30,
		quality			    = THUMB_QUALITY,
	},
	thumb50 = {
		type				= CT_SQUARE,
		size				= 50,
		quality			    = THUMB_QUALITY,
	},
	thumb150 = {
		type				= CT_SQUARE,
		size				= 150,
		quality			    = THUMB_QUALITY,
	},
	thumb180 = {
		type				= CT_SQUARE,
		size				= 180,
		quality		    	= THUMB_QUALITY,
	},
	thumb300 = {
		type				= CT_SQUARE,
		size				= 300,
		quality			    = THUMB_QUALITY,
	},
	square = {
		type				= CT_SQUARE,
		size				= 80,
		quality			    = THUMB_QUALITY,
	},
	test = {
		type				= CT_SQUARE,
		size				= 100,
		quality			    = TEST_QUALITY,
	},
	cover = {
		type				= CT_SQUARE,
		size				= 200,
		quality			    = THUMB_QUALITY,
	},
	sq612 = {
		type				= CT_SQUARE,
		size				= 612,
		quality			    = QUALITY_90,
	},
	thumbnail = {
		type				= CT_MAX_SIZE,
		size				= 120,
		quality			    = THUMB_QUALITY,
	},
	ms160 = {
		type				= CT_MAX_SIZE,
		size				= 160,
		quality			    = THUMB_QUALITY,
	},
	small = {
		type				= CT_MAX_SIZE,
		size				= 200,
		quality			    = THUMB_QUALITY,
		ratio				= 3.0/10,
	},
	bmiddle = {
		type				= CT_MAX_WIDTH,
		size				= 440,
		quality			    = QUALITY_90,
	},
	mw1024 = {
		type				= CT_MAX_WIDTH,
		size				= 1024,
		quality			    = QUALITY_95,
		interlace			= 1,
	},
	mw720 = {
		type				= CT_MAX_WIDTH,
		size				= 720,
		quality			    = THUMB_QUALITY,
		interlace			= 1,
	},
	mw600 = {
		type				= CT_MAX_WIDTH,
		size				= 600,
		quality			    = QUALITY_95,
	},
	mw690 = {
		type				= CT_MAX_WIDTH,
		size				= 690,
		quality			    = QUALITY_95,
		interlace			= 1,
	},
	mw220 = {
		type				= CT_MAX_WIDTH,
		size				= 220,
		quality			    = THUMB_QUALITY,
	},
	mw240 = {
		type				= CT_MAX_WIDTH,
		size				= 240,
		quality			    = THUMB_QUALITY,
	},
	mw205 = {
		type				= CT_MAX_WIDTH,
		size				= 205,
		quality			    = THUMB_QUALITY,
	},
	large = {
		type				= CT_MAX_WIDTH,
		size				= 2048,
		quality			    = QUALITY_95,
	},
	wap720 = {
		type				= CT_MAX_WIDTH,
		size				= 720,
		quality			    = WAP_QUALITY,
	},
	ms080 = {
		type				= CT_MAX_SIZE,
		size				= 80,
		quality			    = THUMB_QUALITY,
	},
	wap800 = {
		type				= CT_MAX_SIZE,
		size				= 800,
		quality			    = WAP_QUALITY,
	},
	wap690 = {
		type				= CT_MAX_SIZE,
		size				= 690,
		quality			    = WAP_QUALITY,
	},
	wap35 = {
		type				= CT_MAX_SIZE,
		size				= 35,
		quality			    = WAP_QUALITY,
	},
	wap50 = {
		type				= CT_MAX_SIZE,
		size				= 50,
		quality			    = WAP_QUALITY,
	},
	wap120 = {
		type				= CT_MAX_SIZE,
		size				= 120,
		quality			    = WAP_QUALITY,
	},
	wap360 = {
		type				= CT_MAX_SIZE,
		size				= 360,
		ratio				= 3.0/10,
		quality			    = WAP_QUALITY,
	},
	wap180 = {
		type				= CT_MAX_SIZE,
		size				= 180,
		ratio				= 3.0/10,
		quality			    = WAP_QUALITY,
	},
	wap128 = {
		type				= CT_PROPORTION,
		cols				= 128,
		rows				= 160,
		quality			    = WAP_QUALITY,
	},
	wap176 = {
		type				= CT_PROPORTION,
		cols				= 176,
		rows				= 220,
		quality			    = WAP_QUALITY,
	},
	wap240 = {
		type				= CT_PROPORTION,
		cols				= 240,
		rows				= 320,
		quality			    = WAP_QUALITY,
	},
	wap320 = {
		type				= CT_PROPORTION,
		cols				= 320,
		rows				= 480,
		quality			    = WAP_QUALITY,
	},
	webp720 = {
		type				= CT_MAX_WIDTH,
		size				= 720,
		quality			    = WAP_QUALITY,
		format				= CF_WEBP,
	},
	webp440 = {
		type				= CT_MAX_WIDTH,
		size				= 440,
		quality			    = QUALITY_90,
		format				= CF_WEBP,
	},
	webp360 = {
		type				= CT_MAX_SIZE,
		size				= 360,
		ratio				= 3.0/10,
		quality			    = WAP_QUALITY,
		format				= CF_WEBP,
	},
	webp180 = {
		type				= CT_MAX_SIZE,
		size				= 180,
		ratio				= 3.0/10,
		quality			    = WAP_QUALITY,
		format				= CF_WEBP,
	},
	crop200 = {
		type				= CT_CROP,
        size                = 200,
		quality			    = QUALITY_90,
	},
}

local function square(size)
    log.print(LOG_DEBUG, "square()...")
    log.print(LOG_DEBUG, "size: " .. size)
    local ret, x, y, cols

    local im_cols = zimg.cols()
    local im_rows = zimg.rows()
    log.print(LOG_DEBUG, "im_cols: " .. im_cols)
    log.print(LOG_DEBUG, "im_rows: " .. im_rows)
    if im_cols > im_rows then
        cols = im_rows
        y = 0
        x = math.ceil((im_cols - im_rows)/2)
    else
        cols = im_cols
        x = 0
        y = math.ceil((im_rows - im_cols)/2)
    end
    log.print(LOG_DEBUG, "x: " .. x)
    log.print(LOG_DEBUG, "y: " .. y)

    ret = zimg.crop(x, y, cols, cols)
    log.print(LOG_DEBUG, "zimg.crop(" .. x .. ", " .. y .. ", ".. cols .. ", " .. cols .. ") ret = " .. ret)
    if ret ~= WI_OK then
        return TS_FAILED
    end

    ret = zimg.scale(size, size)
    log.print(LOG_DEBUG, "zimg.scale(" .. size .. ", " .. size .. ") ret = " .. ret)
    if ret ~= WI_OK then
        log.print(LOG_DEBUG, "square() failed")
        return TS_FAILED
    end

    log.print(LOG_DEBUG, "square() succ")
    return TS_OK
end

local function max_width(arg)
    log.print(LOG_DEBUG, "max_width()...")
    local ret, ratio, cols, rows 
    local im_cols = zimg.cols()
    local im_rows = zimg.rows()
    log.print(LOG_DEBUG, "im_cols: " .. im_cols)
    log.print(LOG_DEBUG, "im_rows: " .. im_rows)
    log.print(LOG_DEBUG, "arg.size: " .. arg.size)
    if im_cols <= arg.size then
        log.print(LOG_DEBUG, "im_cols <= arg.size return.")
        return TS_OK
    end

    cols = arg.size
    log.print(LOG_DEBUG, "cols = " .. cols)
    if arg.ratio then
        ratio = im_cols / im_rows
        if ratio < arg.ratio then
            cols = im_cols
            rows = math.ceil(cols / arg.ratio)
            if rows > im_rows then
                rows = im_rows
            end
            ret = zimg.crop(0, 0, cols, rows)
            log.print(LOG_DEBUG, "zimg.crop(" .. 0 .. ", " .. 0 .. ", ".. cols .. ", " .. rows .. ") ret = " .. ret)
            if ret ~= WI_OK then
                return TS_FAILED
            end
        else
            cols = math.min(arg.size, im_cols)
            rows = im_rows

            ret = zimg.crop(0, 0, cols, rows)
            log.print(LOG_DEBUG, "zimg.crop(" .. 0 .. ", " .. 0 .. ", ".. cols .. ", " .. rows .. ") ret = " .. ret)
            if ret == WI_OK then
                return TS_OK
            else
                return TS_FAILED
            end
        end
    else
        rows = math.ceil((cols / im_cols) * im_rows);
        ret = zimg.scale(cols, rows)
        log.print(LOG_DEBUG, "zimg.scale(" .. cols .. ", " .. rows .. ") ret = " .. ret)
        if ret == WI_OK then
            return TS_OK
        else
            return TS_FAILED
        end
    end
end

local function max_size(arg)
    log.print(LOG_DEBUG, "max_size()...")
    local ret, ratio, rows, cols
    local im_cols = zimg.cols(im)
    local im_rows = zimg.rows(im)

    if im_cols <= arg.size and im_rows <= arg.size then
        return TS_OK
    end

    if arg.ratio then
        ratio = im_cols / im_rows
        log.print(LOG_DEBUG, "ratio = " .. ratio)
        if im_cols < (arg.size * arg.ratio) and ratio < arg.ratio then
            cols = im_cols
            rows = math.min(im_rows, arg.size)

            ret = zimg.crop(0, 0, cols, rows)
            log.print(LOG_DEBUG, "zimg.crop(" .. 0 .. ", " .. 0 .. ", ".. cols .. ", " .. rows .. ") ret = " .. ret)
            if (ret == WI_OK) then
                return TS_OK 
            else
                return TS_FAILED
            end
        end
        if im_rows < (arg.size * arg.ratio) and ratio > (1.0 / arg.ratio) then
            rows = im_rows
            cols = math.min(im_cols, arg.size)

            ret = zimg.crop(0, 0, cols, rows)
            log.print(LOG_DEBUG, "zimg.crop(" .. 0 .. ", " .. 0 .. ", ".. cols .. ", " .. rows .. ") ret = " .. ret)
            if (ret == WI_OK) then
                return TS_OK
            else
                return TS_FAILED
            end
        end

        if im_cols > im_rows and ratio > (1.0 / arg.ratio) then
            rows = im_rows
            cols = rows / arg.ratio
            if (cols > im_cols) then
                cols = im_cols
            end

            ret = zimg.crop(0, 0, cols, rows)
            log.print(LOG_DEBUG, "zimg.crop(" .. 0 .. ", " .. 0 .. ", ".. cols .. ", " .. rows .. ") ret = " .. ret)
            if (ret ~= WI_OK) then
                return TS_FAILED
            end
        elseif ratio < arg.ratio then
            cols = im_cols
            rows = cols / arg.ratio
            if (rows > im_rows) then
                rows = im_rows
            end
            ret = zimg.crop(0, 0, cols, rows)
            log.print(LOG_DEBUG, "zimg.crop(" .. 0 .. ", " .. 0 .. ", ".. cols .. ", " .. rows .. ") ret = " .. ret)
            if (ret ~= WI_OK) then
                return TS_FAILED
            end
        end
    end

    if im_cols > im_rows then
        cols = arg.size
        rows = math.ceil((cols / im_cols) * im_rows);
    else
        rows = arg.size
        cols = math.ceil((rows / im_rows) * im_cols);
    end

    ret = zimg.scale(cols, rows)
    log.print(LOG_DEBUG, "zimg.scale(" .. cols .. ", " .. rows .. ") ret = " .. ret)
    if ret == WI_OK then
        return TS_OK
    else
        return TS_FAILED
    end
end

local function proportion(arg)
    log.print(LOG_DEBUG, "proportion()...")
	local ret, ratio, cols, rows
    local im_cols = zimg.cols()
    local im_rows = zimg.rows()

	ratio = im_cols / im_rows
	if arg.ratio and ratio > arg.ratio then
		cols = arg.cols
		if im_cols < cols then
            return TS_OK
        end
        rows = math.ceil((cols / im_cols) * im_rows);
	else
		rows = arg.rows
		if im_rows < rows then
            return TS_OK
        end
        cols = math.ceil((rows / im_rows) * im_cols);
    end

	ret = zimg.scale(cols, rows)
    log.print(LOG_DEBUG, "zimg.scale(" .. cols .. ", " .. rows .. ") ret = " .. ret)
	if ret == WI_OK then
        return TS_OK
    else
        return TS_FAILED
    end
end

local function crop(arg)
    log.print(LOG_DEBUG, "crop()...")
    local ret, x, y, cols, rows
    local im_cols = zimg.cols()
    local im_rows = zimg.rows()

    if arg.cols then
        cols = arg.cols
    else
        cols = arg.size
    end
    if arg.rows then
        rows = arg.rows
    else
        rows = arg.size
    end

    if cols > im_cols then
        cols = im_cols
    end
    if rows > im_rows then
        rows = im_rows
    end

    x = math.ceil((im_cols - cols) / 2.0);
    y = math.ceil((im_rows - rows) / 2.0);

    ret = zimg.crop(x, y, cols, rows)
    log.print(LOG_DEBUG, "zimg.crop(" .. x .. ", " .. y .. ", ".. cols .. ", " .. rows .. ") ret = " .. ret)
    if ret ~= WI_OK then
        return TS_FAILED
    end
    return TS_OK
end

function f()
    local code = TS_FAILED
    local rtype = zimg.type()
    log.print(LOG_DEBUG, "rtype:" .. rtype)

    local arg = type_list[rtype]
    if arg then
        local ret = -1
        log.print(LOG_DEBUG, "arg.type = " .. arg.type)
        local switch = {
            [CT_SQUARE]         = function()    ret = square(arg.size)     end,
            [CT_MAX_WIDTH]      = function()    ret = max_width(arg)       end,
            [CT_MAX_SIZE]       = function()    ret = max_size(arg)        end,
            [CT_PROPORTION]     = function()    ret = proportion(arg)      end,
            [CT_CROP]           = function()    ret = crop(arg)            end,
            [CT_NONE]           = function()    ret = TS_OK                end,
        }
        log.print(LOG_DEBUG, "start scale image...")
        local action = switch[arg.type]
        if action then
            action()
            if ret == TS_OK then
                if arg.quality and zimg.quality() > arg.quality then
                    log.print(LOG_DEBUG, "zimg.quality = " .. zimg.quality())
                    zimg.set_quality(arg.quality)
                    log.print(LOG_DEBUG, "zimg.set_quality(" .. arg.quality .. ")")
                end

                local format = zimg.format()
                log.print(LOG_DEBUG, "zimg.format() = " .. format)
                if not string.find(format, "GIF") then
                    log.print(LOG_DEBUG, "not GIF, change")
                    if arg.format and arg.format == CF_WEBP then
                        log.print(LOG_DEBUG, "arg.format = WEBP")
                        ret = zimg.set_format("WEBP")
                    else
                        log.print(LOG_DEBUG, "arg.format = JPEG")
                        ret = zimg.set_format("JPEG")
                    end
                else
                    log.print(LOG_DEBUG, "GIF, donot change")
                end

                code = ret
                log.print(LOG_DEBUG, "code = " .. code)
            else
                log.print(LOG_DEBUG, "scale image failed.")
            end
        else
            log.print(LOG_DEBUG, "action = nil")
        end
    else
        log.print(LOG_DEBUG, "arg = nil")
    end

    zimg.ret(code)
    log.print(LOG_DEBUG, "zimg lua script finished.")
end

log.print(LOG_DEBUG, "zimg using lua script.")

