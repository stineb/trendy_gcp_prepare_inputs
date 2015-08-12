df <- read.table( 'global_co2_ann_1860_2014.out', col.names=c('year','co2') )
df.ext <- data.frame( year=1500:1859, co2=df$co2[1] )
df <- rbind( df.ext, df )
write.table( df, file='global_co2_ann_1500_2014.out', sep="  ", row.names=FALSE, col.names=FALSE )