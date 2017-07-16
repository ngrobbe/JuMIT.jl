__precompile__()

module IO

import SIT.F90libs

"""
Read an input SeismicUnix file and output 
the time-domain data as `Data.TD`.

# Arguments
* `fname::AbstractString` : name of the SeismicUnix file
TODO: conversion to `TD`, currently the ouput is just a data matrix.
"""
function readsu_data(;
		     fname::AbstractString="", verbose::Bool=false
		     )
	isfile(fname) ? nothing : error("file does not exist")

	nt = [0]; nrecords = [0];
	# read number of time samples and number of records first 
	ccall( (:readsu_nt_nrecords, F90libs.io), Void, 
       (Ptr{UInt8}, Ref{Int64}, Ref{Int64}),
	      fname, nt, nrecords); 
	nt = nt[1]; nrecords = nrecords[1];

	verbose ? println("readsu_data: nt = ", string(nt)) : nothing
	verbose ? println("readsu_data: nrecords = ", string(nrecords)) : nothing
	data = zeros(nt, nrecords);

	# read data now 
	ccall( (:readsu_data_fast, F90libs.io), Void, 
	      (Ptr{UInt8}, Ref{Int64}, Ref{Int64}, Ptr{Float64}),
	      fname, nt, nrecords, data);

	(maximum(abs, data) == 0.0) && warn("readsu_data is zeros")
	return reshape(data, (nt, nrecords)), nt, nrecords
end



end # module
