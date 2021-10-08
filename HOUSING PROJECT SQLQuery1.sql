SELECT * FROM [2.0portfolioproject]..HousingProject

--CHANGE SALE DATE FORMAT

SELECT SaleDate, CONVERT(date,SaleDate)
FROM [2.0portfolioproject]..HousingProject

UPDATE [2.0portfolioproject]..HousingProject 
SET SaleDate = CONVERT (date,SaleDate)

ALTER TABLE [2.0portfolioproject]..HousingProject
ADD SaleDateconverted date;

UPDATE [2.0portfolioproject]..HousingProject
SET SaleDateconverted =  CONVERT (date,SaleDate)

SELECT SaleDateconverted
FROM [2.0portfolioproject]..HousingProject


--POPULATE PROPERTY ADRESS

SELECT PropertyAddress
FROM [2.0portfolioproject]..HousingProject
WHERE PropertyAddress IS NULL

SELECT *
FROM [2.0portfolioproject]..HousingProject
WHERE PropertyAddress IS NULL

SELECT *
FROM [2.0portfolioproject]..HousingProject A
JOIN [2.0portfolioproject]..HousingProject B
    ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM [2.0portfolioproject]..HousingProject A
JOIN [2.0portfolioproject]..HousingProject B
    ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
	WHERE A.PropertyAddress IS NULL

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL( A.PropertyAddress,B.PropertyAddress)
FROM [2.0portfolioproject]..HousingProject A
JOIN [2.0portfolioproject]..HousingProject B
    ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
	WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL( A.PropertyAddress,B.PropertyAddress)
FROM [2.0portfolioproject]..HousingProject A
JOIN [2.0portfolioproject]..HousingProject B
    ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
	WHERE A.PropertyAddress IS NULL

SELECT PropertyAddress
FROM [2.0portfolioproject]..HousingProject 

--SUCCESSFUL POPULATION OF THE PROPERTY ADDRESS COLUMN

--BREAKING ADDRESS INTO INDIVIDUAL COLUMNS i.e --

SELECT PropertyAddress
FROM [2.0portfolioproject]..HousingProject 

-- To do the separation we have to remove the deliminator in this case the comma (,)introduce a substring and character index--

SELECT

SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS ADDRESS,
SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS CITY_NAME 

FROM [2.0portfolioproject]..HousingProject

-- Create new tables to reflect the changes made to the property address

ALTER TABLE [2.0portfolioproject]..HousingProject
ADD SplitAddress Nvarchar(255);

UPDATE [2.0portfolioproject]..HousingProject
SET SplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE [2.0portfolioproject]..HousingProject
ADD SplitCity Nvarchar(255);

UPDATE [2.0portfolioproject]..HousingProject
SET SplitCity =  SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT * 
FROM [2.0portfolioproject]..HousingProject

--SAME CAN BE DONE WITH THE OWNER ADDRESS

SELECT OwnerAddress
FROM [2.0portfolioproject]..HousingProject

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS STATE,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS CITY,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS ADDRESS
FROM [2.0portfolioproject]..HousingProject

--Make changes to the table--

ALTER TABLE [2.0portfolioproject]..HousingProject
ADD SplitState Nvarchar(255);

UPDATE [2.0portfolioproject]..HousingProject
SET SplitState =  PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) 

ALTER TABLE [2.0portfolioproject]..HousingProject
ADD SplitCity Nvarchar(255);

UPDATE [2.0portfolioproject]..HousingProject
SET SplitCity =  PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE [2.0portfolioproject]..HousingProject
ADD SplitAddress Nvarchar(255);

UPDATE [2.0portfolioproject]..HousingProject
SET SplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

SELECT * 
FROM [2.0portfolioproject]..HousingProject


--CHANGE Y,N TO YES, NO IN "Sold as vacant category"

SELECT DISTINCT (SoldAsVacant),COUNT(SoldAsVacant)
FROM [2.0portfolioproject]..HousingProject
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM [2.0portfolioproject]..HousingProject

UPDATE [2.0portfolioproject]..HousingProject
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END

--Remove duplicates--

WITH RowNumCTE AS(
SELECT * ,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					   UniqueID
					   ) row_numb
FROM [2.0portfolioproject]..HousingProject)
SELECT *
FROM RowNumCTE
--Check for duplicates

WITH RowNumCTE AS(
SELECT * ,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					   UniqueID
					   ) row_numb
FROM [2.0portfolioproject]..HousingProject)
SELECT *
FROM RowNumCTE
WHERE row_numb >1

--Delete duplicates--

WITH RowNumCTE AS(
SELECT * ,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					   UniqueID
					   ) row_numb
FROM [2.0portfolioproject]..HousingProject)
DELETE
FROM RowNumCTE
WHERE row_numb >1

--Removing unnecesarry rows--

SELECT *
FROM [2.0portfolioproject]..HousingProject

ALTER TABLE [2.0portfolioproject]..HousingProject
DROP COLUMN PropertyAddress, SaleDate,OwnerAddress