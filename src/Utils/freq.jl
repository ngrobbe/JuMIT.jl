

"""
Return the normalized and stacked (along dim=1) power spectra of time series x in dB 
as an AxisArray.
"""
function stacked_power_spectra(x, fs=1.0)
	# allocate rfft domain
	cx=rfft(x,[1]); # rfft along first dimension
	
	abs2.(cx) #  
	for i in CartesianIndices(size(cx))
		rmul!()
		if(1≤i[1]≤nttb)
			x[i] *= sin((i[1]-1)*kb)
		end
		if(nt-ntte+1≤i[1]≤nt)
			x[i] *= sin((-i[1]+nt)*ke)
		end
	end


end

function findfreq(
		  x::Array{Float64, ND},
		  tgrid::Grid.M1D;
		  attrib::Symbol=:peak,
		  threshold::Float64=-50.
		  ) where {ND}

	fgrid=Grid.M1D_rfft(tgrid);

	ax = (abs.(cx).^2); # power spectrum in dB

	if(maximum(ax) == 0.0)
		warn("x is zero"); return 0.0
	else 
		ax /= maximum(ax);
		ax = 10. .* log10.(ax)
	end

	if(attrib == :max)
		iii=findlast(ax .>= threshold)
	elseif(attrib == :min)
		iii=findfirst(ax .>= threshold)
	elseif(attrib == :peak)
		iii=argmax(ax)
	end
	ii=ind2sub(size(ax),iii)[1]
	return fgrid.x[ii]

end


