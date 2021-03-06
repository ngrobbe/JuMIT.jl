

"""
Compare if two `TD`'s  are equal
"""
function Base.isequal(dat1::TD, dat2::TD)
	fnames = fieldnames(TD)
	vec=[(isequal(getfield(dat1, name),getfield(dat2, name))) for name in fnames]
	return all(vec)
end

"""
Return if two `TD`'s have same dimensions and bounds.
"""
function Base.isapprox(dat1::TD, dat2::TD)
	vec=([ 
		isequal(dat1.tgrid, dat2.tgrid),
		isequal(dat1.fields, dat2.fields),
		isequal(dat1.acqgeom, dat2.acqgeom, :receivers), # only receivers have to be the same
       		(size(dat1.d)==size(dat2.d)), 
		])
	vec2=[size(dat1.d[iss,ifield])==size(dat2.d[iss,ifield]) for iss=1:dat1.acqgeom.nss, ifield=1:length(dat1.fields)]
	return (all(vec) & all(vec2))
end

function Base.length(data::TD)
	nr = data.acqgeom.nr;	nss = data.acqgeom.nss;	nt = data.tgrid.nx;
	l=0
	for ifield = 1:length(data.fields), iss = 1:nss
		for ir = 1:nr[iss]
			for it in 1:nt
				l+=1
			end
		end
	end
	return l
end

"""
Return a vec of data object sorted in the order
time, receivers, supersource, fields
"""
function Base.vec(data::TD)
	nr = data.acqgeom.nr;	nss = data.acqgeom.nss;	nt = data.tgrid.nx;
	v=Vector{Float64}()
	for ifield = 1:length(data.fields), iss = 1:nss
		dd=data.d[iss, ifield]
		append!(v,dd)
	end
	return v
end


"""
Method to Devectorize data!
No memory allocations
"""
function Base.copyto!(dataout::TD, v::Vector{Float64})
	nr = dataout.acqgeom.nr;	nss = dataout.acqgeom.nss;	nt = dataout.tgrid.nx;
	dout=getfield(dataout, :d)
	i0=0
	for iss=1:nss, ifield=1:length(dataout.fields)
		ddout=dout[iss,ifield]
		for ir = 1:nr[iss]
			for it in 1:nt
				ddout[it,ir]=v[i0+it]
			end
			i0+=nt
		end
	end
	return dataout
end


"""
Method to vectorize data!
No memory allocations
"""
function Base.copyto!(v::Vector{Float64}, data::TD)
	nr = data.acqgeom.nr;	nss = data.acqgeom.nss;	nt = data.tgrid.nx;
	d=getfield(data, :d)
	i0=0
	for iss=1:nss, ifield=1:length(data.fields)
		dd=d[iss,ifield]
		for ir = 1:nr[iss]
			for it in 1:nt
				v[i0+it]=dd[it,ir]
			end
			i0+=nt
		end
	end
	return v
end

"""
Fill with randn values
"""
function Random.randn!(data::TD)
	nr = data.acqgeom.nr;	nss = data.acqgeom.nss;	nt = data.tgrid.nx;
	for ifield = 1:length(data.fields), iss = 1:nss
		dd=data.d[iss, ifield]
		Random.randn!(dd)
	end
	return data
end





"""
Copy `TD`'s, which are similar.
"""
function Base.copyto!(dataout::TD, data::TD)
	if(isapprox(dataout, data))
		dout=getfield(dataout, :d)
		din=getfield(data, :d)
		for iss=1:data.acqgeom.nss, ifield=1:length(data.fields)
			ddout=dout[iss,ifield]
			ddin=din[iss,ifield]
			copyto!(ddout,ddin)
		end
		return dataout
	else
		error("attempt to copy dissimilar data")
	end
end


"""
Returns bool depending on if input `data::TD` has all zeros or not.
"""
function Base.iszero(data::TD)
	return maximum(broadcast(maximum,abs,data.d)) == 0.0 ? true : false
end


"""
Returns dot product of data.

# Arguments 

* `data1::TD` : data 1
* `data2::TD` : data 2

# Return

* dot product as `Float64`
"""
function LinearAlgebra.dot(data1::TD, data2::TD)
	if(isapprox(data1, data2))
		dotd = 0.0;
		for ifield = 1:length(data1.fields), iss = 1:data1.acqgeom.nss 
			for ir = 1:data1.acqgeom.nr[iss], it = 1:data1.tgrid.nx
				dotd += data1.d[iss, ifield][it, ir] * data2.d[iss, ifield][it, ir]
			end
		end
		return dotd
	else
		error("cannot dot dissimilar datasets")
	end
end


