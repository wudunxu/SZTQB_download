library(rvest)
library(qpdf)

start_date <- as.Date("20230103", format="%Y%m%d")
end_date <- as.Date("20230320", format="%Y%m%d")
rangea <- seq(start_date, end_date, by="days")
rangeb <- format(rangea,"%Y%m/%d")

for (j in seq_along(rangeb)){
  # 读取网页
  url <- paste0("http://sztqb.sznews.com/PC/layout/",rangeb[j],"/node_A01.html")
  pg <- read_html(url)
  
  # 提取所有a标签中的href属性
  links <- html_attr(html_nodes(pg, "a"), "href")
  
  # 筛选出以.pdf结尾的链接
  pdf_links <- links[grepl("\\.pdf$", links)]
  pdf_links <- sub("^\\.\\./\\.\\./\\.\\./\\.\\./", "http://sztqb.sznews.com/", pdf_links)
  pdf_links <- unique(pdf_links)
  
  # 创建一个空向量用于存储新文件名
  new_names <- vector()
  
  # 循环下载每个pdf文件，并按照顺序编号重命名
  for (i in seq_along(pdf_links)) {
    # 获取原文件名
    old_name <- basename(pdf_links[i])
    # 生成新文件名，格式为"编号-原文件名"
    new_name <- paste0(i, "-", old_name)
    # 使用repeat语句重复尝试下载直到成功
    repeat {
      # 使用tryCatch()函数捕获错误
      result <- tryCatch({
        # 下载并重命名文件到当前目录
        download.file(pdf_links[i], destfile = new_name, mode = "wb")
        # 返回TRUE表示成功
        TRUE
      }, error = function(e) {
        # 返回FALSE表示失败，并打印错误信息
        print(e)
        FALSE
      })
      
      # 如果result为TRUE，说明下载成功，跳出repeat语句，继续下一个循环
      if (result) break
      
      # 否则，等待5秒后再次尝试下载
      Sys.sleep(5)
    }
    # 将新文件名添加到向量中
    new_names <- c(new_names, new_name)
  }
  
  # 合并所有下载的pdf文件为一个新文件，命名
  name <- paste0(rangea[j],".pdf")
  qpdf::pdf_combine(input = new_names, output = name)
  
  # 删除之前下载的pdf文件
  unlink(new_names)
}


