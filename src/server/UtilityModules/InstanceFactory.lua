local InstanceFactory = {}

function InstanceFactory.createInstance(instanceType, name, parent)
    local newInstance = Instance.new(instanceType)
    newInstance.Name = name
    newInstance.Parent = parent
    return newInstance
end

return InstanceFactory