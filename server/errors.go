package server

import "errors"

var (
	ErrNotImplement   = errors.New("no implement")
	ErrNoKey          = errors.New("no key in url")
	ErrNotAllowed     = errors.New("file type is not allowed")
	ErrObjectTooLarge = errors.New("object too large")
	ErrObjectNotFound = errors.New("object no found")
	ErrObjectDeleted  = errors.New("object deleted")
	ErrBadimg         = errors.New("bad image, broken or not supported.")
	ErrPoolOverflow   = errors.New("too many requests, resource overflow.")
)
