###
# determine the number of years of doubling require for a 100km to reach speed of light 
# 20210128
# carverd@colostate.edu
###

# initial state 
x <- 100 
# speed of light in kilometers per hour 
sol <- 1079000000 

n = 1 
while(x < sol){
  print(x) 
  x <- x*2
  n = n+1
}
### number of iterations required 
print(n)
# if double occurs every year, in what year would the car break the speed of light 
1899+n

