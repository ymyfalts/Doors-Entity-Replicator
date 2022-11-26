return function(calledByRandom, EntitiesFunctions)
    if calledByRandom==true then
        return EntitiesFunctions[math.random(1,#EntitiesFunctions)](true)
    end
    for entity,_ in pairs(EntitiesFunctions) do
        if entity~="All" and entity~="Random" then
            EntitiesFunctions[entity]()
        end
    end
end