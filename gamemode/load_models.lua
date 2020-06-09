local modelsDir = GM.FolderName .. "/content/models/"

local modelCategories, _ = file.Find( modelsDir .. "*", "LUA" )

for _, modelCategory in pairs( modelCategories ) do
    local modelCategoryDir = modelsDir .. modelCategory .. "/"

    local _, models = file.Find( modelCategoryDir .. "*.mdl", "LUA" )

    for _, model in pairs( models ) do
        local modelPath = modelCategoryDir .. model

        resource.AddFile( modelPath )
    end
end

local materialsDir = GM.FolderName .. "/content/materials/models/"

local materialCategories, _ = file.Find( materialsDir .. "*", "LUA" )

for _, materialCategory in pairs( materialCategories ) do
    local materialCategoryDir = materialsDir .. materialCategory .. "/"

    local _, materials = file.Find( materialCategoryDir .. "*.mdl", "LUA" )

    for _, material in pairs( materials ) do
        local materialPath = materialCategoryDir .. material

        resource.AddFile( materialPath )
    end
end
