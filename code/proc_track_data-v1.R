

library(terra)
library(sf)
library(dplyr)

fl <- "C:/Users/JG/Desktop/PPPP_final_240919.kml"


lyrs <- st_layers(fl)

#pb <- txtProgressBar(1,nrow(lyrs), style=3)

cli::cli_progress_bar(
  total = nrow(lyrs),
  format = "Processed: | {cli::pb_bar} {cli::pb_percent}"
)

for(i in 1:nrow(lyrs)){

      pp <- st_read(fl, layer = lyrs$name[i], quiet = TRUE) %>% 
        st_zm(drop = TRUE, what = "ZM")
      
      filtered_pp <- pp[st_geometry_type(pp) %in% c("LINESTRING", "MULTILINESTRING"), ]
      
      filtered_pp <- try(filtered_pp %>% 
        st_cast(to="LINESTRING") %>% 
        mutate(track_name = lyrs$name[i]))
      
      if(inherits(filtered_pp,"try-error")){
        filtered_pp <- try(filtered_pp %>% 
                             #st_cast(to="LINESTRING") %>% 
                             mutate(track_name = lyrs$name[i]))
        
      }
  
  if(i==1){
    trks <- filtered_pp
  }else{
    
    test_it <- try(trks %>% bind_rows(filtered_pp))
    
    if(inherits(test_it,"try-error")){
      
      cat(":: An error occurred for:\n\n")
      print(pp)
      cat("\n\n")
      
      next
    }else{
      trks <- trks %>% bind_rows(filtered_pp)
    }
  }
  
  cli::cli_progress_update(set = i)
  #setTxtProgressBar(pb, i)
}

readr::write_rds(trks, "./data/vector/percursos_pedestres-24092019.rds")

write_sf(trks,"./data/vector/percursos_pedestres-24092019.shp")

write_sf(trks,"./data/vector/percursos_pedestres-24092019", driver="GeoJSON")


