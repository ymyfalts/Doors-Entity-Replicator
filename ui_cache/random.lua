return function(_,_,_,_,_,spawnEntity, entities)
    local selectedEntity
    repeat selectedEntity=entities.AllEntities[math.random(1,#entities.AllEntities)] wait() until selectedEntity~="Random" and selectedEntity~="All" and selectedEntity~="None"
    spawnEntity(selectedEntity)
end
