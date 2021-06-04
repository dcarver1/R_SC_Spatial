###
# script to call summary html
# 20210428
# carverd@colostate.edu 
### 
install.packages("rmarkdown")
library(rmarkdown)


# input features 
baseDir <- "F:/R_SC_Spatial/intermediateGeospatialR/"
county <- "Bexar"
months <- c("april", "may", "june", "july")
filters <- c(2,6,10)

#define input rmd 
inputFile <- paste0(baseDir,"/src/countySummaries.Rmd")

## <<- define a global variable so elements edited here will be observed within the rmd 

# all datasets will be defined in the RMD as relative locations to the baseDir defined here

# generate the file  
rmarkdown::render(inputFile,
                  output_file=paste0("summary_",county))


## or itorate the process 
counties <- c("Bexar", "Brazoria", "Harris")
for(i in counties){
  county <<- i 
  # generate the file  
  rmarkdown::render(inputFile,
                  output_file=paste0("summary_",county))
}


