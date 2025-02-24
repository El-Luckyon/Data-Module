--!strict
--!native
--!optimize 2

export type mode = "INFO" | "DEBUG" | "TRACE"

export type formatedOut = (logger : {prefix : string}, formatString : string, ...any) -> ()

export type logger = {
    prefix : string,
    debugf : formatedOut,
    printf : formatedOut,
    errorf : formatedOut,
    warnf : formatedOut,
    tracef : formatedOut,
}

local function empty(_logger : {prefix : string}, _formatString : string, ... : any) : ()
    local _ = ...
end

local function printf(logger : {prefix : string}, formatString : string, ... : any) : ()
    print(logger.prefix..string.format(formatString, ...))
end

local function warnf(logger : {prefix : string}, formatString : string, ... : any) : ()
    warn(logger.prefix..string.format(formatString, ...))
end

local function errorf(logger : {prefix : string}, formatString : string, ... : any) : ()
    error(logger.prefix..string.format(formatString, ...), 2)
end

local function createTrace(prefix : string) : logger
    return {
        prefix = prefix,
        debugf = printf,
        printf = printf,
        errorf = errorf,
        tracef = printf,
        warnf = warnf,
    }
end

local function createDebug(prefix : string) : logger
    return {
        prefix = prefix,
        debugf = printf,
        printf = printf,
        errorf = errorf,
        tracef = empty,
        warnf = warnf,
    }
end

local function createInfo(prefix : string) : logger
    return {
        prefix = prefix,
        debugf = empty,
        printf = printf,
        errorf = errorf,
        tracef = empty,
        warnf = warnf,
    }
end

local function createLogger(prefix : string, mode : mode) : logger
    prefix = prefix.." ["..mode.."] "
    local logger = mode == "DEBUG" and createDebug(prefix) or mode == "TRACE" and createTrace(prefix) or createInfo(prefix)
    return table.freeze(logger)
end

return table.freeze{
    new = createLogger,
}