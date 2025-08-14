from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

options = Options()
options.add_argument('--lang=id')
options.add_argument('accept-language=id:ID,id')
driver = webdriver.Chrome(options=options)

wait = WebDriverWait(driver, 15)

url = "https://www.tokopedia.com/sepatukanky/kanky-street-rc-02-by-rico-lubis-sepatu-basketball-pria-dewasa-1731046375082591529"
driver.get(url)

try:
    product_name = driver.find_element(By.CSS_SELECTOR, '[data-testid="lblPDPDetailProductName"]').text.strip()
    rating_number = driver.find_element(By.CSS_SELECTOR, '[data-testid="lblPDPDetailProductRatingNumber"]').text.strip()
    rating_counter = driver.find_element(By.CSS_SELECTOR, '[data-testid="lblPDPDetailProductRatingCounter"]').text.strip()
    product_price = driver.find_element(By.CSS_SELECTOR, '[data-testid="lblPDPDetailProductPrice"]').text.strip()

    sold_count = driver.find_element(By.CSS_SELECTOR, '[data-testid="lblPDPDetailProductSoldCounter"]').text.strip()

    shop_name = wait.until(EC.presence_of_element_located(
        (By.CSS_SELECTOR, 'div[data-testid="llbPDPFooterShopName"] h2')
    )).text.strip()

    rating_element = driver.find_element(By.CSS_SELECTOR, 'div.css-e39d2g p')
    
    spans = rating_element.find_elements(By.TAG_NAME, 'span')
    shop_rating = spans[0].text.strip()
    shop_rating_counter = spans[1].text.strip()

except Exception as e:
    print("Error:", e)
    product_name = rating_number = rating_counter = product_price = sold_count =  'unknown'
    shop_name = shop_rating = shop_rating_counter = 'unknown'

print(product_name)
print(rating_number)
print(rating_counter)
print(product_price)
print(sold_count)
print(shop_name)
print(shop_rating)
print(shop_rating_counter)

driver.quit()
