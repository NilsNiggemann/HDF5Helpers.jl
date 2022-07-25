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

function h5Merge(target::String,origin::String,Groups=h5keys(origin);MainGroup = "")
    h5open(origin,"r") do f
        for key in Groups
            data = read(f[key])
            try
                h5write(target,MainGroup *"/"*key,data)
            catch e
                @warn "Merging of field $key errored with exception :\n $e "
            end
        end
    end
end

function H5mergeFiles(targetFile,files;Groups = 1:length(files))

    for (i,f) in enumerate(files)
        h5Merge(targetFile,f,MainGroup = Groups[i])
        mv(f,joinpath(fntemp,basename(f)))
    end
end

allOccurIn(name,args...) = all((occursin(arg,name) for arg in args))
findNames(names,args...) = findall(x->allOccurIn(x,args...),names)
NameFilter(names,args...) = filter(x->allOccurIn(x,args...),names)
OnlyIndex(names,args...) = only(findNames(names,args...))