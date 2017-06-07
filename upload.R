## This short script contains the code necessary to link R to WordPress
# This endeavour ultimately failed because WordPress does not allow my computer
# to ping the website often enough to problem solve some of the issues
# So I decided on a manual workflow to get the content to the blog

# The required libraries
# install.packages("devtools")
# install_github("duncantl/XMLRPC")
# install_github("duncantl/RWordPress")
# install.packages("knitr")
library(devtools)
library(RCurl)
library(XML)
library(XMLRPC)
library(RWordPress)
library(knitr)
library(markdown)

# Set options
options(WordpressLogin = c(admin = "OceanCode13"),
        WordpressURL = "http://kelpsandthings.org/robert/xmlrpc.php")

options(WordPressLogin = c(admin = "OceanCode13"),
        WordPressURL = "http://kelpsandthings.org/robert/xmlrpc.php")


# Set other options
# options(WordpressLogin = c(wiederweiter = "14themoney"),
#         WordpressURL = "https://wiederweiter.wordpress.com/xmlrpc.php")
# 
# options(WordPressLogin = c(wiederweiter = "14themoney"),
#         WordPressURL = "https://wiederweiter.wordpress.com/xmlrpc.php")

# Check
getUsersBlogs(login = c(admin = "OceanCode13"), .server = "http://kelpsandthings.org/robert/xmlrpc.php")


# Include toc
# options(markdown.HTML.options =  c(markdownHTMLOptions(default = T),"toc"))

# Upload plots: set knitr options
opts_knit$set(upload.fun = function(file){library(RWordPress);uploadFile(file)$url;})

# Upload featured image / post thumbnail: option: wp_post_thumbnail=postThumbnail$id
# postThumbnail <- RWordPress::uploadFile("figure/post_thumbnail.png", overwrite = TRUE)

# Knit a draft of the article to WordPress
knit2wp("text/test.Rmd", title = "Test")

knit2wp("text/religious_sentiment.Rmd", title = "Religious Sentiment", publish = FALSE, action = c("newPost"))


## Update existing post with R Markdown
# Find most recent post id's
head(getRecentPostTitles(login = c(admin = "OceanCode13"), .server = "http://kelpsandthings.org/robert/xmlrpc.php"))
posts <- getRecentPostTitles(login = c(admin = "OceanCode13"), .server = "http://kelpsandthings.org/robert/xmlrpc.php")
# OR
postid <- as.character(posts[1,"postid"]) # assuming it's the last entry

# Get the post id from recent posts
# posts <- getRecentPostTitles(num = 1, blogid = 0L, login = getOption("WordpressLogin",
#                                                                      stop("need a login and password")))
postid <- as.character(posts[1,"postid"]) # assuming it's the last entry

# Get the post
post <- getPost(postid=postid, login = getOption("WordpressLogin", 
                                                 stop("need a login and password")))

# Edit the post (keep category,tags and title as before)
knit2wp('PublishBlogPosts.Rmd',postid=postid, action = c("editPost"),title=post$title,
        categories=post$categories,mt_keywords=post$mt_keywords,
        wp_post_thumbnail=post$wp_post_thumbnail,publish=FALSE)


## Further testing
if (!require('RWordPress')){install.packages('RWordPress', repos = 'http://www.omegahat.org/R', type = 'source')}
library(RWordPress)
options(WordpressLogin = c(admin = 'OceanCode13'), WordpressURL = 'http://kelpsandthings.org/robert/xmlrpc.php')
options(WordpressLogin = c(wiederweiter = '14themoney'), WordpressURL = 'https://wiederweiter.wordpress.com/xmlrpc.php')
options(WordpressLogin = c(wiederweiter = '14themoney'), WordpressURL = 'http://kelpsandthings.org/robert/xmlrpc.php')
library(knitr)
# Knitr options: upload plots/images to wordpress
opts_knit$set(upload.fun = function(file){library(RWordPress);uploadFile(file)$url;})
# enable toc (comment out if not needed)
library(markdown)
options(markdown.HTML.options =  c(markdownHTMLOptions(default = T),"toc"))

# Upload featured image / post thumbnail: option: wp_post_thumbnail=postThumbnail$id
# postThumbnail <- RWordPress::uploadFile("figure/post_thumbnail.png",overwrite = TRUE)

postid <- knit2wp('RMarkdownWordpressTemplate.rmd', action = c("newPost"),title = 'RMarkdown Wordpress Template',categories=c('R'),mt_keywords = c('R','RMarkdown'),publish=FALSE) # ad
postid <- knit2wp('text/test.Rmd', action = c("newPost"),title = 'Test',categories=c('R'),mt_keywords = c('R','RMarkdown'),publish=FALSE) # ad



id <- knit2wp('text/religious_sentiment.Rmd', title = 'Religious Sentiment',
              shortcode = c(T, T), action = 'newPost',
              publish = F)
