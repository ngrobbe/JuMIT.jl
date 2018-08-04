

function add_born_sources!(issp::Int64, pac::Paramc, pass::Vector{Paramss}, pap::Paramp)

	born_svalue_stack=pass[issp].born_svalue_stack
	δx24I=pac.δx24I; δz24I=pac.δz24I; 
	δxI=pac.δxI; δzI=pac.δzI; 
	δt=pac.δt
	δtI=pac.δtI
	δmodtt=pac.δmodtt; modttI=pac.modttI;
	δmodrrvx=pac.δmodrrvx; δmodrrvz=pac.δmodrrvz
	nx=pac.nx; nz=pac.nz
	p=pap.p; pp=pap.pp; ppp=pap.ppp;
	dpdx=pap.dpdx; dpdz=pap.dpdz;

	# secondary sources for Born modeling
	# adding born sources from pressure(:,:,1) to pressure(:,:,2)
	# upto until [it-2]
	# lambdaI scatterrer source term at [it-1]
	# p is at [it], pp is at [it-1], ppp is at [it-2]
	# dpdx is at [it-1] and dpdz is at [it-1]
	# modrrvx scatterrer source term at [it-1]
	# modrrvz scatterrer source term at [it-1]

	born_stacktt!(born_svalue_stack,p,pp,ppp,δmodtt,nx,nz,δtI,δt)
	born_stackrrvx!(born_svalue_stack,dpdx,δmodrrvx,nx,nz,δx24I,δt)
	born_stackrrvz!(born_svalue_stack,dpdz,δmodrrvz,nx,nz,δz24I,δt)
	born_stack!(p,born_svalue_stack,modttI,nx,nz,δt)
end
@inbounds @fastmath function born_stacktt!(born_svalue_stack,p,pp,ppp,δmodtt,nx,nz,δtI,δt)
	for ix=3:nx-2
		@simd for iz=3:nz-2
			born_svalue_stack[iz,ix] += 
			δt * ((-1.0 * (ppp[iz, ix, 1,1] + p[iz, ix,  1,1] - 2.0 * pp[iz, ix,  1,1]) * δmodtt[iz, ix] * δtI * δtI)) 
		end
	end
end
@inbounds @fastmath function born_stackrrvx!(born_svalue_stack,dpdx,δmodrrvx,nx,nz,δx24I,δt)
	for ix=3:nx-2
		@simd for iz=3:nz-2
			born_svalue_stack[iz,ix] += 
				δt * ((27.e0*dpdx[iz,ix,1,1] * δmodrrvx[iz,ix] -27.e0*dpdx[iz,ix-1,1,1] * δmodrrvx[iz,ix-1] -dpdx[iz,ix+1,1,1] * δmodrrvx[iz,ix+1] +dpdx[iz,ix-2,1,1] * δmodrrvx[iz,ix-2] ) * (δx24I)) 
		end
	end

end
@inbounds @fastmath function born_stackrrvz!(born_svalue_stack,dpdz,δmodrrvz,nx,nz,δz24I,δt)
	for ix=3:nx-2
		@simd for iz=3:nz-2
			born_svalue_stack[iz,ix] += 
				δt * ((27.e0*dpdz[iz,ix,1,1] * δmodrrvz[iz,ix] -27.e0*dpdz[iz-1,ix,1,1] * δmodrrvz[iz-1,ix] -dpdz[iz+1,ix,1,1] * δmodrrvz[iz+1,ix] +dpdz[iz-2,ix,1,1] * δmodrrvz[iz-2,ix] ) * (δz24I))  

		end
	end
end
@inbounds @fastmath function born_stack!(p,born_svalue_stack,modttI,nx,nz,δt)
	for ix=3:nx-2
		@simd for iz=3:nz-2
			p[iz,ix,1,2] += born_svalue_stack[iz,ix] * modttI[iz,ix] * δt  #* δxI * δzI 
		end
	end
end

