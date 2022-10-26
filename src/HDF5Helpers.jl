module HDF5Helpers
using HDF5

include("reading.jl")
export h5keys,h5path,getKeyswith,readGroupElements,ArrayReadGroupElements,readLastGroupElements,getReadablekeys,repairHDF5File,joinGroup,getFilesFromSubDirs

include("H5merge.jl")
export getSourceFilesWith,h5write,h5merge,allOccurIn,findNames,NameFilter,OnlyIndex
end # module
