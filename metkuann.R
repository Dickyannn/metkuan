# Memuat paket yang diperlukan
library(dplyr)
library(readxl)
library(car)
library(MASS)
library(ggplot2)
library(ResourceSelection)

# Membaca data
social_ads <- read_excel("SMT4/Sesi UAS/Metkuan/PROJEK/social_ads.xlsx")

# Membuat kolom AgeGroup berdasarkan usia
social_ads <- social_ads %>%
  mutate(AgeGroup = cut(Age, breaks = c(17, 25, 35, 45, 55, 65), labels = c("18-25", "26-35", "36-45", "46-55", "56-65")))

# Memeriksa distribusi sampel
table(social_ads$AgeGroup)

# Menampilkan hasil sampel berlapis
View(stratified_sample)

# Buat boxplot
ggplot(social_ads, aes(x = AgeGroup, y = EstimatedSalary, fill = AgeGroup)) +
  geom_boxplot() +
  labs(title = "Boxplot Estimated Salary by Age Group",
       x = "Age Group", y = "Estimated Salary") +
  theme_minimal()


# Jumlah sampel yang diinginkan untuk setiap AgeGroup
n1 <- 25
n2 <- 65
n3 <- 60
n4 <- 38
n5 <- 14

# Melakukan random sampling untuk setiap AgeGroup
sample_agegroup_1 <- social_ads %>%
  filter(AgeGroup == "18-25") %>%
  slice_sample(n = n1, replace = FALSE)

sample_agegroup_2 <- social_ads %>%
  filter(AgeGroup == "26-35") %>%
  slice_sample(n = n2, replace = FALSE)

sample_agegroup_3 <- social_ads %>%
  filter(AgeGroup == "36-45") %>%
  slice_sample(n = n3, replace = FALSE)

sample_agegroup_4 <- social_ads %>%
  filter(AgeGroup == "46-55") %>%
  slice_sample(n = n4, replace = FALSE)

sample_agegroup_5 <- social_ads %>%
  filter(AgeGroup == "56-65") %>%
  slice_sample(n = n5, replace = FALSE)

# Menggabungkan data yang sudah di-sampling untuk setiap AgeGroup
sample_data <- bind_rows(sample_agegroup_1, sample_agegroup_2, sample_agegroup_3, sample_agegroup_4, sample_agegroup_5)

# Menampilkan hasil random sampling
View(sample_data)

# Eksplorasi data
summary(sample_data)

# Konversi AgeGroup menjadi faktor
sample_data$AgeGroup <- as.factor(sample_data$AgeGroup)

# Matriks korelasi antara Purchased dan AgeGroup
correlation_purchased_age <- cor(as.numeric(sample_data$Purchased), as.numeric(sample_data$Age))
print("Korelasi antara Purchased dan Age:")
print(correlation_purchased_age)

# Matriks korelasi antara Purchased dan EstimatedSalary
correlation_purchased_salary <- cor(as.numeric(sample_data$Purchased), sample_data$EstimatedSalary)
print("Korelasi antara Purchased dan EstimatedSalary:")
print(correlation_purchased_salary)


# Pembagian data training dan testing
set.seed(123)  # Set seed untuk reproduksibilitas
training_data <- sample_data %>%
  slice_sample(prop = 0.7)  # 70% untuk training set
testing_data <- sample_data %>%
  setdiff(., training_data)  # 30% untuk testing set

# Model regresi logistik biner pada data training
logistic_model <- glm(Purchased ~ Age + EstimatedSalary, 
                      data = training_data, family = binomial)
summary(logistic_model)

# Pengujian multikolinearitas dengan VIF
vif(logistic_model)

# Deteksi leverage
hat_values <- hatvalues(logistic_model)
summary(hat_values)


# Deteksi pencilan
residuals_deviance <- residuals(logistic_model, type = "deviance")
summary(residuals_deviance)


# Menambahkan garis referensi untuk deteksi pencilan
#abline(h = c(-2, 2), col = "blue", lty = 2)  # Garis untuk threshold pencilan


# Deteksi amatan berpengaruh
influence_measures <- influence.measures(logistic_model)
summary(influence_measures)

# Uji Hosmer-Lemeshow
hoslem.test(training_data$Purchased, fitted(logistic_model))

# Uji normalitas Shapiro-Wilk untuk residual
shapiro.test(residuals_deviance)
# Membuat Q-Q plot untuk residual
qqnorm(residuals_deviance)
qqline(residuals_deviance)


## Deteksi Outlier
stud_resids <- studres(logistic_model)
studres <- data.frame(stud_resids)

# plot predictor variable vs. studentized residuals
plot(training_data$Age, stud_resids, ylab='Studentized Residuals', xlab='Age')
abline(0, 0)

plot(training_data$EstimatedSalary, stud_resids, ylab='Studentized Residuals', xlab='EstimatedSalary')
abline(0, 0)

# Prediksi
training_data$Predicted_Purchased <- predict(logistic_model, type = "response")

# Gabungkan semua data
full_data <- cbind(training_data, studres)

# Tampilkan data lengkap
View(full_data)

## Evaluasi Model pada Data Testing
# Prediksi pada data testing
testing_data$Predicted_Purchased <- predict(logistic_model, newdata = testing_data, type = "response")

# Evaluasi metrik
confusion_matrix <- table(testing_data$Purchased, ifelse(testing_data$Predicted_Purchased > 0.5, 1, 0))
print("Confusion Matrix:")
print(confusion_matrix)

accuracy <- (sum(diag(confusion_matrix)) / sum(confusion_matrix)) * 100
precision <- ifelse(sum(confusion_matrix[,1]) == 0, 0, (confusion_matrix[1, 1] / (sum(rowSums(confusion_matrix)[1]))) * 100)
recall <- ifelse(sum(confusion_matrix[1,]) == 0, 0, (confusion_matrix[1, 1] / (sum(colSums(confusion_matrix)[1]))) * 100)
f1_score <- ifelse(precision + recall == 0, 0, 2 * ((precision * recall) / (precision + recall)))

# Print metrics with rounding to 2 decimal places
print(paste("Akurasi:", round(accuracy, digits = 2)))
print(paste("Presisi:", round(precision, digits = 2)))
print(paste("Recall:", round(recall, digits = 2)))
print(paste("F1 Score:", round(f1_score, digits = 2)))


# ROC curve
library(pROC)
roc_curve <- roc(testing_data$Purchased, testing_data$Predicted_Purchased)
roc_auc <- auc(roc_curve)
plot(roc_curve, main = paste("ROC Curve (AUC =", round(roc_auc, 2), ")"))

# Interpretasi Model
summary(logistic_model)

# Visualisasi hubungan antara variabel
library(ggplot2)
ggplot(training_data, aes(x = Age, y = EstimatedSalary, color = factor(Purchased))) +
  geom_point() +
  scale_color_discrete(name = "Purchased", breaks = c(0, 1), labels = c("No", "Yes")) +
  labs(title = "Relationship between Age, Estimated Salary and Purchased",
       x = "Age",
       y = "Estimated Salary") +
  theme_minimal()

    
# K-means clustering dengan 2 kluster berdasarkan Purchased
set.seed(123)
kmeans_result <- kmeans(sample_data[, c("Age", "EstimatedSalary")], centers = 2, nstart = 20)
sample_data$Cluster <- as.factor(kmeans_result$cluster)

# Visualisasi hasil K-means clustering
ggplot(sample_data, aes(x = Age, y = EstimatedSalary, color = Cluster)) +
  geom_point() +
  labs(title = "K-means Clustering with 2 Clusters",
       x = "Age",
       y = "Estimated Salary") +
  theme_minimal()

# Interpretasi hasil K-means
print("Centroid kluster:")
print(kmeans_result$centers)
print("Jumlah data dalam setiap kluster:")
print(table(sample_data$Cluster))

# Menambahkan informasi Purchased ke hasil K-means
sample_data$Purchased <- as.factor(sample_data$Purchased)

# Melihat distribusi Purchased dalam setiap kluster
table(sample_data$Cluster, sample_data$Purchased)
