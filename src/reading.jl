function h5keys(f,Group::String ="")
    isempty(Group) && return keys(f)
    return keys(f[Group])
end

function h5keys(Filename::String,Group::String ="")
    h5open(Filename,"r") do f
        h5keys(f,Group)
    end
end

function h5keys(File,Group::Int)
    GroupStr = h5keys(File)[Group]
    h5keys(File,GroupStr)
end

function h5path(File,Groups::Int...)
    FullGroupStr = ""
    for g in Groups
        GroupStr = h5keys(File,FullGroupStr)[g]
        FullGroupStr = FullGroupStr*"/"*GroupStr
    end
    return FullGroupStr
end

function h5keys(File,Groups::Int...)
    FullGroupStr = h5path(File,Groups...)
    h5keys(File,FullGroupStr)
end

function getKeyswith(f,key::String,Groups...)
    keys = h5keys(f,Groups...)
    filter!(x->occursin(key,x),keys)
end

"""Fetches key from file for each group and appends results to a list"""
function readGroupElements(File::AbstractString,key)
    h5open(File,"r") do f
        readGroupElements(f,key)
    end
end

function readGroupElements(f::HDF5.File,key)
    return [Array(f[string(Group,"/",key)]) for Group in keys(f)]
end

function ArrayReadGroupElements(File,key)
    Data = readGroupElements(File,key)
    d = size(first(Data)) |> length
    return cat(Data...,dims = d+1)
end

function readLastGroupElements(File::AbstractString,key)
    h5open(File,"r") do f
        readLastGroupElements(f,key)
    end
end

function readLastGroupElements(f,key)
    return VectorOfArray([ Array(f[string(Group,"/",key)])[end,..] for Group in keys(f)]) #using EllipsisNotation to get index in first dimension
end


function getReadablekeys(fn::AbstractString)
    k = h5open(fn) do f
        ks = keys(f)
        readableIndices = Int[]
        for i in eachindex(ks)
            try
                read(f,ks[i])
                push!(readableIndices,i)
            catch
            end
        end
        return ks[readableIndices]
    end
end

function repairHDF5File(fn::AbstractString,newfile = fn)
    dir = dirname(fn)
    mkpath(dir*"/temp")
    
    tempfile = joinpath(dir,"temp/",basename(fn))
    mv(fn,tempfile)
    
    readablekeys = getReadablekeys(tempfile)
    h5Merge(newfile,tempfile,readablekeys)
end
