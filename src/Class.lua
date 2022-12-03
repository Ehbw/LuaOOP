local noop = function () end
local Class = {}

---@generic T
---@param Prototype T
---@return table
function Class.new(Prototype)
    local class = {
        __index = function (self, index, ...)
            local prototype = Prototype[index]
            if prototype then
                if type(prototype) == 'function' then
                    return function(...)
                        return prototype(self, ...)
                    end
                end
            end

            if index == 'private' or index == 'protected' then
                return nil
            end

            if self.private and self.private[index] then
                return self.private[index]
            end

            if self.private and self.protected[index] then
                return self.protected[index]
            end
        end,
        __gc = function (self)
            if self.destruct then
                self.destruct()
            end
        end,
        private = setmetatable({}, {
            __ext = 0,
            __pack = noop,
        }),
        protected = setmetatable({}, {
            __ext = 0,
            __pack = noop,
        })
    }

    setmetatable(class, {
        __call = function (self, param)
            if param then
                if not param.private then
                    param.private = {}
                end
                if not param.protected then
                    param.protected = {}
                end
            end
            local instance = setmetatable(param or {private = {}, protected = {}}, self)
            if instance.construct then
                instance.construct()
            end
            return instance
        end
    })

    return class
end

function Class.Inherit(BaseClass)
    local newClass = setmetatable({}, {
        __index = BaseClass.__index or BaseClass,
        __call = function (self, param)
            local class = Class.new(self)
            return getmetatable(class).__call(class, param)
        end
    })
    return newClass
end

return Class


