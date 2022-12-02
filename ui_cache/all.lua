return function(_,_,_,_,_,spawnEntity, entities)
    for _, entity in pairs(entities.AllEntities) do
        if entity~="All" and entity~="Random" then
            spawnEntity(entity)
        end
    end
end
