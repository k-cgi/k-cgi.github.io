
library(rvest)

seed_gen <- "cymbidium"
seed_grex <- ""

poll_gen <- "cymbidium"
poll_grex <- ""

output_file <- "./RNA/cym/cym_hibrid_list_2.csv"


if (seed_gen!=""){
seed_gen <- paste("&seedgen=",seed_gen,sep="")
}

if (seed_grex!=""){
seed_grex <- paste("&seedgrex=",seed_grex,sep="")
}

if (poll_gen!=""){
poll_gen <- paste("&pollgen=",poll_gen,sep="")
}

if (poll_grex!=""){
poll_grex <- paste("&pollgrex=",poll_grex,sep="")
}

serch_str <- paste(seed_gen,seed_grex,poll_gen,poll_grex,sep="")


html_1=read_html(paste("https://apps.rhs.org.uk/horticulturaldatabase/orchidregister/parentageresults.asp?page=1",serch_str,sep=""))
row_names <- matrix(c("Gen","Epi","Registrant_Name","Orginator_Name","Date_of_Registration","Seed_gen","Seed_grex","Poll_gen","Poll_grex","Synonym Name"),nrow=1,ncol=10)


####ページ数を抽出
page_num <- html_text(html_nodes(html_1,"h3"))
page_num <- as.integer(sub("Page 1 of ","",page_num[1]))

###掲載種数を抽出
epi_num <- html_text(html_nodes(html_1,"h2")) 
epi_num <- epi_num[1]
epi_num <- sub("There","",epi_num)
epi_num <- sub("are","",epi_num)
epi_num <- sub(" hits","",epi_num)
epi_num <- sub("is","",epi_num)
epi_num <- sub(" hit","",epi_num)
epi_num <- as.integer(substr(epi_num,3,nchar(epi_num)))


last_num <- epi_num%%20 ###最終ページの掲載種数
if (last_num == 0){
	last_num =20
}


#####page_num=1　###再開用

write.table(row_names, output_file, quote=F,col.names=F,row.names=F, append=T, sep=",")
all_data<- NULL

for (i in 1:page_num){  
	html_all=read_html(paste("https://apps.rhs.org.uk/horticulturaldatabase/orchidregister/parentageresults.asp?page=", i, serch_str,sep=""))
	
		if (i==page_num){	
			sp_num=last_num ###最終ページの場合
		} else{
			sp_num=20
		}
		####IDを抽出
		ID_url <- html_all %>% html_nodes(xpath="//a") %>% html_attr("href")
		if (page_num==1){
			ID_url <- head(ID_url, n=last_num)
			ID_url <- tail(ID_url, n=last_num)
			"a"
		}else if (i==1||i==page_num){			
			ID_url <- head(ID_url, n=sp_num+page_num)
			ID_url <- tail(ID_url, n=sp_num)
			"B"
		}else{						###最初と最後以外はリンクが１つ多い(Next pageのボタン)
			ID_url <- head(ID_url, n=sp_num+page_num+1)	
			ID_url <- tail(ID_url, n=sp_num)
			"C"
		}


		for (j in 1:sp_num){  ###各ページに載ってるデータを取得

			###種ごとのデータあつめ
			html_ID=read_html(paste("https://apps.rhs.org.uk/horticulturaldatabase/orchidregister/", ID_url[j],sep=""))
			html_tab<- html_table(html_ID)
			ID_url[j]
			####シノニムかどうか確認

			##交配種名 gen=属名 epi=交配名 reg_name 登録者 org_name 交配者 DOR 登録日
			gen <- html_tab[[1]]$X2[1]
			epi <- html_tab[[1]]$X2[2]
			syn <- html_tab[[1]]$X2[3]
			if (syn =="This is not a synonym"){		
				if (length(html_tab[[1]]$X2)==8){		###本当はシノニムであるとき(登録ミス)
					syn_name <-  paste(html_tab[[1]]$X2[4],html_tab[[1]]$X2[5])
					reg_name <- html_tab[[1]]$X2[6]
					org_name <- html_tab[[1]]$X2[7]
					DOR <- html_tab[[1]]$X2[8]
				} else{						###シノニムじゃないとき(真)
					syn_name <- ""
					reg_name <- html_tab[[1]]$X2[4]
					org_name <- html_tab[[1]]$X2[5]
					DOR <- html_tab[[1]]$X2[6]
				}
			} else{
				if (length(html_tab[[1]]$X2)==8){		###シノニム名が登録されてあるとき
					syn_name <-  paste(html_tab[[1]]$X2[4],html_tab[[1]]$X2[5])
					reg_name <- html_tab[[1]]$X2[6]
					org_name <- html_tab[[1]]$X2[7]
					DOR <- html_tab[[1]]$X2[8]
				} else{						###シノニム名が登録されてないとき
					syn_name <- "Synonym"
					reg_name <- html_tab[[1]]$X2[4]
					org_name <- html_tab[[1]]$X2[5]
					DOR <- html_tab[[1]]$X2[6]
				}
			}

			##両親情報 seedgen種子親属名 seedei種子親交配名 polgen花粉親属名 polepi花粉親交配名
			seedgen <- html_tab[[2]]$"Seed parent"[1]
			seedepi <- html_tab[[2]]$"Seed parent"[2]

			polgen <- html_tab[[2]]$"Pollen parent"[1]
			polepi <- html_tab[[2]]$"Pollen parent"[2]

			all_data<- rbind(all_data,c(gen,epi,reg_name,org_name,DOR,seedgen,seedepi,polgen,polepi,syn_name))
			Sys.sleep(1)
		}
Sys.sleep(2)
write.table(all_data, output_file, quote=F,col.names=F,row.names=F, append=T, sep=",")
all_data <-NULL
}

all_data <-NULL
###############END################


####../../RNA/cym/cym_hibrid_list.csv
