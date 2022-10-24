function getSourceFilesWith(key::String,Dir::String)
    Dir .* filter!(x -> occursin(key,x), readdir(Dir))
end

import HDF5.h5write

function HDF5.h5write(filename::String,Group::String,Data::Dict)
    for (key,val) in Data
        h5write(filename,Group*"/"*key,val)
    end
end

HDF5.h5write(filename::String,Data::Dict) = HDF5.h5write(filename::String,"",Data::Dict)

recursive_merge(x::AbstractDict...) = merge(recursive_merge, x...)
recursive_merge(x::AbstractVector...) = cat(x...; dims=1)
recursive_merge(x...) = x[end]

function h5merge(target::String,files,MainGroups = nothing)
    
    dicts0 = read.(h5open.(files))
    dicts =
    if MainGroups === nothing
        dicts0
    elseif length(MainGroups) == length(files)
        dicts = [Dict([MG => d,]) for (MG,d) in zip(MainGroups,dicts0)]
    else
        error("could not merge files using specified groups!")
    end
    dict = recursive_merge(dicts...)
    h5write(target,dict)
end

function H5mergeFiles(targetFile,files;Groups = (nothing for _ in files))
    for (f,MainGroup) in zip(files,Groups)
        h5Merge(targetFile,f;MainGroup)
    end
end


joinGroup(args...) = join(args,"/")
joinGroup(::Nothing,args...) = join(args)

allOccurIn(name,args...) = all((occursin(arg,name) for arg in args))
findNames(names,args...) = findall(x->allOccurIn(x,args...),names)
NameFilter(names,args...) = filter(x->allOccurIn(x,args...),names)
OnlyIndex(names,args...) = only(findNames(names,args...))