setFlaggedValuesToNA <- function (gM=NULL, rM=NULL, wM=NULL, fv=NULL) {

  if (is.null(gM) || is.null(rM) || is.null(wM) || is.null(fv)){
    stop("gM, rM, and wM matrix required; also flagvalue fv");
  }
  
  for(i in 1:nrow(wM)) {
    for(j in 1:ncol(wM)) {
      if (wM[i,j] == fv) {
        rM[i,j] = NA;
        gM[i,j] = NA;
      }
    }
  }

  res = list(G=gM, R=rM);

  return(res);
}


#--------------------------------------------------------------------------------
