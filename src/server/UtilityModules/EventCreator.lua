local EventCreator = {}

function EventCreator.createEvent(type, name, location)
	local newEvent = Instance.new(type)
	newEvent.Name = name
    newEvent.Parent = location
	return newEvent
end

return EventCreator