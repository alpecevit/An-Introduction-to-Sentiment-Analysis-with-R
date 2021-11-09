# Basic Introduction to Sentiment Analysis / *Duygu Analizi'ne Giriş*
  This notebook is going to give a brief introduction to what is called the "Sentiment Analysis" with the Twitter data. This notebook includes both Turkish and 
  English explanations so that the native Turkish speakers can benefit from it as well. Italic writings are in Turkish.
  
  *Bu notebook "Duygu Analizi"ne Twitter datası kullanılarak giriş yapmaktadır. Kod açıklamalarında İngilizce ve Türkçe beraber kullanılacaktır, bu sayede ana dili 
  Türkçe olan bireyler de bu notebook'tan tamamen faydalanabilecektir*

# Coding Language / *Kullanılacak Kodlama Dili*
  As the coding language this notebook is going to use R. The data frame that this notebook is going to use will be the public Airlines Tweets data set. The 
  necessary packages and the data set will all be provided.
  
  *Kodlama dili olarak R programlama dili kullanılacaktır. Veri seti olark da halka açık veri seti olan Airlines Tweets veri seti kullanılacaktır. Gerekli paketler
  ve veri seti bu notebook içinde yer alacaktır.*
  
# Necessary Packages and Data Set / *Yüklenmesi Gerekli Paketler ve Veri Seti*
  The necessary packages for this notebook are indicated below: 
  - `tidytext`
  - `tidyverse`
  - `ggplot2`
  - `forcats`
  - `wordcloud`
  - `textdata`
  - `lda`
  - `tm`
  - `topicmodels`
  
  First, you need to install these packages by using the `install.packages("package_name_here")` function and then use `library(package_name_here)` function to
  access these packages.
  
  *Notebook içinde kullanılacak gerekli paketler aşağıda listelenmiştir:*
  - `tidytext`
  - `tidyverse`
  - `ggplot2`
  - `forcats`
  - `wordcloud`
  - `textdata`
  - `lda`
  - `tm`
  - `topicmodels`

  *Bu paketleri indirebilmek için öncelikle `install.packages("buraya_paket_ismi_yazılacak")` fonksiyonu kullanılacak, daha sonra bu paketlere erişebilmek için de
  `library(buraya_paket_ismi_yazılacak)` fonksiyonu kullanılacaktır.*
