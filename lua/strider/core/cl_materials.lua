
local mats = {}
function strider.Material(path, opts)
    opts = opts or "none"
    if mats[path .. opts] then
        return mats[path .. opts]
    end

    mats[path .. opts] = Material(path, opts)
    return mats[path .. opts]
end

local named = {}
function strider.NamedCache(name, fn)
    if named[name] then
        return named[name]
    end

    named[name] = fn()
    return named[name]
end