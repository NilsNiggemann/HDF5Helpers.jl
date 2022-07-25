function h5keys(Filename::String)
    h5open(Filename,"r") do f
        return keys(f)
    end
end

"""Fetches key from file for each group and appends results to a list"""
function readGroupElements(File,key)
    h5open(File,"r") do f
        return [Array(f[string(Group,"/",key)]) for Group in keys(f)]
    end
end

function ArrayReadGroupElements(File,key)
    Data = readGroupElements(File,key)
    d = size(first(Data)) |> length
    return cat(Data...,dims = d+1)
end

function readLastGroupElements(File,key)
    h5open(File,"r") do f
        return VectorOfArray([ Array(f[string(Group,"/",key)])[end,..] for Group in keys(f)]) #using EllipsisNotation to get index in first dimension
    end
end

joinGroup(args...) = join(args,"/")

function getReadablekeys(fn)
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

function repairHDF5File(fn,newfile = fn)
    dir = dirname(fn)
    mkpath(dir*"/temp")
    
    tempfile = joinpath(dir,"temp/",basename(fn))
    mv(fn,tempfile)
    
    readablekeys = getReadablekeys(tempfile)
    h5Merge(newfile,tempfile,readablekeys)
end
