reorderAndAverageColumns <- function (pl=NULL, df=NULL, isFirstColNames=TRUE) {

  if (is.null(pl) || is.null(df)){
    stop("DataFrame df and pairlist pl must be passed to this function");
  }

  res = list(id=NULL, data=NULL);
  
  if(isFirstColNames) {
   res$id = as.vector(df[,1]);
 }

  groupNames = rownames(summary(pl));

  for(i in 1:length(groupNames)) {
    sampleGroupName = groupNames[i];

    samples = as.vector(pl[[sampleGroupName]]);

    colAverage = averageSamples(v=samples, df=df);

    res$data = cbind(res$data, colAverage);
  }

  groupNames[1] = paste("ID\t", groupNames[1], sep="");
  colnames(res$data) = groupNames;
  
  return(res);
}

#--------------------------------------------------------------------------------

averageSamples <- function(v=NULL, df=NULL) {

  if (is.null(v) || is.null(df)) {
    stop("DataFrame df and vector must be passed to this function");
  }

  dfNames = names(df);

  groupMatrix = NULL;
  
  for(i in 1:length(v)) {
    colNm = v[i];

    index = findIndex(array=dfNames, value=colNm);

    groupMatrix = cbind(groupMatrix, df[,index]);
  }

  return(rowMeans(groupMatrix, na.rm=T));
}



#--------------------------------------------------------------------------------

findIndex <- function (array=NULL, value=NULL) {
  if (is.null(array) || is.null(value)) {
    stop("Array and value must be passed to findIndex function");
  }

  res=NULL;
  
  for(i in 1:length(array)) {

    if(value == array[i]) {
      return(i);
    }
  }
  print(value);
  stop("Could not findIndex");
}


#--------------------------------------------------------------------------------

percentileMatrix <- function(m=NULL) {

  if (is.null(m)) {
    stop("Matrix m must be passed to findIndex function");
  }

  my.rank = vector();
  
  for(j in 1:ncol(m)) {
    my.rank = cbind(my.rank, rank(m[,j]));
  }
    
  res = (my.rank * 100) / nrow(my.rank);

  colnames(res) = colnames(m);

  return(res);
}

#--------------------------------------------------------------------------------


write.expr.profile.individual.files <- function(p=NULL, m=NULL, v=NULL, ext=".txt") {

  if (is.null(v) || is.null(m) || is.null(p)){
    stop("Matrix m and p and Vector v must be passed to this function");
  }

  filenames = paste(gsub("\\s", "", colnames(m), perl=TRUE), ext, sep="");

  my.colnames = c("id\tmean", "percentile");
  
  for(j in 1:ncol(m)) {
    write.table(cbind(m[,j], p[,j]), file=filenames[j], quote=F, sep="\t", row.names=v, col.names=my.colnames)
  }
}

#--------------------------------------------------------------------------------

mOrInverse <- function (df=NULL, ds=NULL) {

  if (is.null(df) || is.null(ds)){
    stop("data.frame df and vector ds are required.");
  }

  for(j in 1:length(ds)) {
    dye.swap.sample = ds[j];

    df[[dye.swap.sample]] = df[[dye.swap.sample]] * -1;
  }
  
  return(df);
}

#--------------------------------------------------------------------------------
