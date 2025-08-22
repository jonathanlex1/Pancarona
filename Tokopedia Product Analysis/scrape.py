from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import pandas as pd 
import time 
import os 

def scraper_configuration(language:str=None) :
    language = language.lower()
    options = Options()
    options.add_argument(f'--lang={language}')
    options.add_argument(f'accept-{language}={language.upper()},{language}')
    return webdriver.Chrome(options=options)
    

def scrapping(language:str=None, url:str=None, product_for:str=None) :
    driver = scraper_configuration(language=language)
    wait = WebDriverWait(driver, 10)

    driver.get(url)

    #scrolling the page
    for _ in range(5) : 
        driver.execute_script("window.scrollBy(0, 500);")
        time.sleep(0.5)

    try :
        #getting product name
        product_name = driver.find_element(By.CSS_SELECTOR, '[data-testid="lblPDPDetailProductName"]').text.strip()
    except : 
        product_name = 'unknown'

    try :
        #getting product rating number
        rating_number = driver.find_element(By.CSS_SELECTOR, '[data-testid="lblPDPDetailProductRatingNumber"]').text.strip()
    except : 
        rating_number = 'unknown'

    try :
        #getting product rating counter
        rating_counter = driver.find_element(By.CSS_SELECTOR, '[data-testid="lblPDPDetailProductRatingCounter"]').text.strip()
    except : 
        rating_counter = 'unknown'

    try :
        #getting product satisfaction
        satisfaction = driver.find_element(By.CLASS_NAME, 'css-pvuwlr-unf-heading.e1qvo2ff8').text.strip()
    except : 
        satisfaction = 'unknown'

    try :
        #getting product price
        product_price = driver.find_element(By.CSS_SELECTOR, '[data-testid="lblPDPDetailProductPrice"]').text.strip()
    except : 
        product_price = 'unknown'

    try :
        #getting number reviews
        number_reviews = driver.find_element(By.CSS_SELECTOR,'p[data-testid="reviewSortingSubtitle"]').text.strip()
    except : 
        number_reviews = 'unknown'

    try :
        #getting number sold of product
        sold_count = driver.find_element(By.CSS_SELECTOR, '[data-testid="lblPDPDetailProductSoldCounter"]').text.strip()
    except : 
        sold_count = 'unknown'

    try :
        #getting shop name of product
        shop_name = wait.until(EC.presence_of_element_located(
            (By.CSS_SELECTOR, 'div[data-testid="llbPDPFooterShopName"] h2')
        )).text.strip()
    except : 
        shop_name = 'unknown'

    try :
        #getting rating element
        rating_element = driver.find_element(By.CSS_SELECTOR, 'div.css-e39d2g p')
        spans = rating_element.find_elements(By.TAG_NAME, 'span')
        #getting shop rating
        shop_rating = spans[0].text.strip()
    except : 
        shop_rating = 'unknown'

    try :
        #getting rating element
        rating_element = driver.find_element(By.CSS_SELECTOR, 'div.css-e39d2g p')
        spans = rating_element.find_elements(By.TAG_NAME, 'span')
        #getting number of shop rating
        shop_rating_counter = spans[1].text.strip()
    except : 
        shop_rating_counter = 'unknown'
        
    data_product_dict = {
    'product_name' : product_name,
    'rating_number' : rating_number,
    'rating_counter' : rating_counter,
    'product_price' : product_price,
    'number_reviews' : number_reviews,
    'sold_count' : sold_count,
    'satisfaction' : satisfaction,
    'shop_name' : shop_name,
    'shop_rating' : shop_rating,
    'shop_rating_counter' :shop_rating_counter,
    'product_for' : product_for
    }

    driver.quit()

    return data_product_dict
    

if __name__ == '__main__' : 
   
    folder_path = 'dataset'
    file_name = 'raw_data.csv'
    file_path = os.path.join(folder_path, file_name)

    if not os.path.exists(folder_path) : 
        os.makedirs(folder_path)

    urls = ["https://www.tokopedia.com/femez-official-store/femez-ultra-evo-1-0-sepatu-lari-running-shoes-big-size-jumbo-putih-emas-white-gold-olahraga-voly-flipper-by-femez-outdoor-1730766411038622917?extParam=ivf%3Dtrue%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/femez-official-store/femez-ultra-evo-1-0-sepatu-lari-running-shoes-big-size-jumbo-43-48-putih-biru-white-blue-olahraga-voly-flipper-by-femez-outdoor-1730766400169608389?extParam=ivf%3Dtrue%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/larocking/larocking-arkas-putih-cream-sepatu-sneakers-running-gym-shoes-putih-cream-39-b1404?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/sepatu-eagle-official-store/eagle-sepatu-lari-eterna-running-shoes-1731086657585907330?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/bata-official/power-primetime-inspo-cushion-sepatu-sneakers-olahrga-wanita-running-sport-shoes-1730601599248139947?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/beyoma/sepatu-beyoma-200mx-original-pria-wanita-sneakers-sport-running-shoes-olahraga-free-kotak-box-by051-outdoor-1729618417853368991?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/beyoma/sepatu-beyoma-33y-original-pria-wanita-sneakers-sport-running-shoes-olahraga-free-kotak-box-by042-outdoor-1729612601932352159?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/marelowofficial/marelow-nole-sepatu-sneakers-casual-unisex-wanita-pria-shoes-kerja-outdoor-running-sport-1730642193223026352?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/beyoma/sepatu-beyoma-new-sport-original-pria-wanita-sneakers-sport-running-shoes-olahraga-free-kotak-box-by038-outdoor-1729611989970619039?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/xfourth-97/x-fourth-formax-black-white-sepatu-trainer-olahraga-daily-running-lari-sekolah-pria-wanita-sneakers-kasual-senam-fitness-gym-outdoor-casual-shoes-1730793857268352689?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/keeping/keeping-sepatu-sneakers-pria-sepatu-pria-jogging-sepatu-olanhraga-cowok-gym-sport-shoes-sepatu-running-fleksible-ksr724-1730991967669749044?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/keeping/keeping-sepatu-pria-ringan-joging-sepatu-olahraga-lari-cowok-kasual-running-sport-shoes-outdoor-ksl306-1731706438342509876?extParam=ivf%3Dtrue%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/elfsactive/elfs-active-x-sunder-sepatu-trailblazer-semi-trail-running-hiking-shoes-1731600111468119156?extParam=ivf%3Dtrue%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/onar-street/onarstreet-sepatu-olahraga-voli-badminton-wanita-onar-sepatu-running-gym-shoes-outdoor-1729579698340596233?extParam=ivf%3Dtrue%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/rjtstore/sepatu-pria-running-sport-street-runner-sepatu-import-putih-40?extParam=ivf%3Dtrue%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/beyoma/original-sepatu-beyoma-750-air-sneakers-sport-running-shoes-olahraga-by003-outdoor-1729601222124538527?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/beyoma/original-sepatu-beyoma-new-pibu-pria-wanita-sneakers-sport-running-shoes-olahraga-free-kotak-box-by009-outdoor-1729601502994598559?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/beyoma/sepatu-beyoma-run-sporty-pria-wanita-sneakers-sport-running-shoes-olahraga-free-kotak-box-by016-outdoor-1729602445218515615?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/azawear/aza-run-1-pygmalion-fresh-morning-running-shoes-sepatu-lari-pria-wanita-warna-putih-1731793993553904940?extParam=ivf%3Dtrue%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/azawear/aza-run-1-pygmalion-g-force-running-shoes-sepatu-lari-pria-wanita-warna-acid-lime-1731794007817553196?extParam=ivf%3Dtrue%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/nuevo/nuevo-crosspeed-putih-biru-sepatu-olahraga-lari-pria-outdoor-sport-men-running-shoes-1729582046513563403?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/hypequartersbykickavenue/gumi-sport-running-shoes-pulse-racer-orora-green-1732022632860124854?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/pro-champion/sepatu-lari-running-shoes-hundred-hndrd-softsride-white-gold-black-1730636832877348643?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/pro-champion/new-sepatu-lari-running-original-eagle-shoes-azka-abu-abu-citrun-37-2c13b?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/hundredid/hundred-running-shoes-sprintpace-hrfs-4m142-1731182809264391438?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/azawear/aza-run-1-pygmalion-galaxy-running-shoes-sepatu-lari-pria-wanita-warna-hitam-1731793973534623020?extParam=ivf%3Dtrue%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/tokodesleshoes/desle-shoes-sneakers-geya-running-women-1732238641986045183?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/donatelloofficial/donatello-c3562800-running-shoes-pria-1732002974493869564?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch", "https://www.tokopedia.com/hundredid/hundred-running-shoes-glidepace-hrfs-4m141-1731181505306068238?extParam=ivf%3Dfalse%26keyword%3Drunning+shoes%26search_id%3D202508181609298D3BBA7425E7C902B4NX%26shop_tier%3D2%26src%3Dsearch"]
    
    data_products = [scrapping(language='id', url=url, product_for='Male') for url in urls]
    df_products = pd.DataFrame(data_products)

    if os.path.exists(file_path) :
        df_products.to_csv(file_path, mode='a', index=False, header=False)
    else :
        df_products.to_csv(file_path, index=False)



    

    

    