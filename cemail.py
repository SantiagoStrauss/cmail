from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import (
    WebDriverException,
    NoSuchElementException,
    ElementClickInterceptedException,
    TimeoutException,
)
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import logging
import os
from typing import List, Optional
from dataclasses import dataclass
from contextlib import contextmanager
import traceback
from webdriver_manager.chrome import ChromeDriverManager

####funciona WORKERS
# Constants for Chrome setup
DEFAULT_CHROME_PATH = "/opt/render/project/.chrome/chrome-linux64/chrome-linux64/chrome"
CHROME_BINARY_PATH = os.getenv('CHROME_BINARY', DEFAULT_CHROME_PATH)

@dataclass
class CompromisedData:
    company_name: str
    domain_name: str
    date_breach_occurred: str
    info_breached: str
    accounts_affected: str
    breach_overview: str 

class CompromisedEmailScraper:
    def __init__(self, headless: bool = True):
        self.logger = self._setup_logger()
        self.verify_chrome_binary()
        self.options = self._setup_chrome_options(headless)
        # Remove version specification to automatically get the matching driver
        self.service = ChromeService(
            ChromeDriverManager(driver_version="131.0.6778.108").install()
        )

    def verify_chrome_binary(self) -> None:
        global CHROME_BINARY_PATH  # Declare global variable before usage
        if not os.path.isfile(CHROME_BINARY_PATH):
            fallback_path = os.path.join(os.getcwd(), "chrome", "chrome.exe")
            if os.path.isfile(fallback_path):
                CHROME_BINARY_PATH = fallback_path
            else:
                self.logger.error(f"Chrome binary not found at {CHROME_BINARY_PATH}")
                raise FileNotFoundError(f"Chrome binary not found at {CHROME_BINARY_PATH}")
        
        if not os.access(CHROME_BINARY_PATH, os.X_OK):
            self.logger.error(f"Chrome binary not executable at {CHROME_BINARY_PATH}")
            raise PermissionError(f"Chrome binary not executable at {CHROME_BINARY_PATH}")

    @staticmethod
    def _setup_logger() -> logging.Logger:
        logger = logging.getLogger('compromised_email_scraper')
        if not logger.handlers:
            logger.setLevel(logging.INFO)
            handler = logging.StreamHandler()
            handler.setFormatter(
                logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
            )
            logger.addHandler(handler)
        return logger

    @staticmethod
    def _setup_chrome_options(headless: bool) -> webdriver.ChromeOptions:
        options = webdriver.ChromeOptions()
        
        # Essential options for stability
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        
        if headless:
            options.add_argument('--headless=new')
        
        # Chrome binary path
        options.binary_location = CHROME_BINARY_PATH

        # Performance options
        options.add_argument('--disable-gpu')
        options.add_argument('--disable-extensions')
        options.add_argument('--disable-software-rasterizer')
        options.add_experimental_option('excludeSwitches', ['enable-logging'])
        
        # Custom user agent (optional)
        options.add_argument(
            'user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
            'AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/131.0.6778.108 Safari/537.36'
        )
        return options

    @contextmanager
    def _get_driver(self):
        driver = None
        try:
            driver = webdriver.Chrome(service=self.service, options=self.options)
            self.logger.info("Chrome browser started successfully")
            yield driver
        except WebDriverException as e:
            self.logger.error(f"Failed to start Chrome driver: {e}")
            raise
        finally:
            if driver:
                try:
                    driver.quit()
                except Exception as e:
                    self.logger.error(f"Error closing browser: {e}")
                finally:
                    self.logger.info("Browser closed")

    def scrape(self, url: str, email: str) -> List[CompromisedData]:
        results = []
        try:
            with self._get_driver() as driver:
                driver.get(url)
                self.logger.info(f"Navigating to {url}")
                
                wait = WebDriverWait(driver, 30)

                try:
                    email_input = wait.until(
                        EC.visibility_of_element_located((By.XPATH, self.EMAIL_INPUT_XPATH))
                    )
                    self.logger.info("Email input field found")
                    email_input.clear()
                    email_input.send_keys(email)
                    self.logger.info(f"Email entered: {email}")

                    search_button = driver.find_element(By.XPATH, self.SEARCH_BUTTON_XPATH)
                    search_button.click()
                    self.logger.info("Search button clicked")
                except TimeoutException:
                    self.logger.error("Email input field not found within timeout")
                    return results
                except Exception as e:
                    self.logger.error(f"Error entering email: {e}")
                    return results

                try:
                    wait.until(EC.presence_of_all_elements_located((By.XPATH, self.RESULT_WRAPPER_XPATH)))
                    breach_wrappers = driver.find_elements(By.XPATH, self.RESULT_WRAPPER_XPATH)
                    self.logger.info(f"Found {len(breach_wrappers)} breach wrapper(s)")
                except TimeoutException:
                    self.logger.info("No results found")
                    return results
                except Exception as e:
                    self.logger.error(f"Error waiting for results: {e}")
                    return results

                for idx, wrapper in enumerate(breach_wrappers, start=1):
                    try:
                        breach_items = wrapper.find_elements(By.XPATH, './/div[@class="breach-item"]')
                        self.logger.info(f"Processing breach wrapper {idx} with {len(breach_items)} items")

                        current_data = {}
                        for item in breach_items:
                            try:
                                label_element = item.find_element(By.TAG_NAME, 'b')
                                label = label_element.text.strip(':').lower().replace(' ', '_').replace('originally_', '')
                                value = item.text.split(':', 1)[1].strip()
                                
                                if label == 'company_name' and current_data:
                                    data = CompromisedData(
                                        company_name=current_data.get('company_name', 'N/A'),
                                        domain_name=current_data.get('domain_name', 'N/A'),
                                        date_breach_occurred=current_data.get('date_breach_occurred', 'N/A'),
                                        info_breached=current_data.get('type_of_information_breached', 'N/A'),
                                        accounts_affected=current_data.get('total_number_of_accounts_affected', 'N/A'),
                                        breach_overview=current_data.get('breach_overview', 'N/A')
                                    )
                                    results.append(data)
                                    self.logger.debug(f"Extracted breach: {data}")
                                    current_data = {}
                                
                                current_data[label] = value
                            except NoSuchElementException:
                                self.logger.debug("Necessary sub-elements not found in breach item")
                            except IndexError:
                                self.logger.debug("No value found for label in breach item")
                            except Exception as e:
                                self.logger.error(f"Unexpected error processing breach item: {e}")
                                self.logger.debug(traceback.format_exc())

                        if current_data:
                            data = CompromisedData(
                                company_name=current_data.get('company_name', 'N/A'),
                                domain_name=current_data.get('domain_name', 'N/A'),
                                date_breach_occurred=current_data.get('date_breach_occurred', 'N/A'),
                                info_breached=current_data.get('type_of_information_breached', 'N/A'),
                                accounts_affected=current_data.get('total_number_of_accounts_affected', 'N/A'),
                                breach_overview=current_data.get('breach_overview', 'N/A') 
                            )
                            results.append(data)
                            self.logger.debug(f"Extracted breach: {data}")
                            
                    except Exception as e:
                        self.logger.error(f"Error extracting data from breach wrapper {idx}: {e}")
                        self.logger.debug(traceback.format_exc())

                return results

        except Exception as e:
            self.logger.error(f"Error during scraping: {e}")
            self.logger.debug(traceback.format_exc())
            return results
    @contextmanager
    def _get_driver(self):
        driver = None
        try:
            driver = webdriver.Chrome(service=self.service, options=self.options)
            driver.maximize_window()
            self.logger.info("Chrome browser started successfully")
            yield driver
        except WebDriverException as e:
            self.logger.error(f"Failed to start Chrome driver: {e}")
            raise
        finally:
            if driver:
                try:
                    driver.quit()
                except Exception as e:
                    self.logger.error(f"Error closing browser: {e}")
                finally:
                    self.logger.info("Browser closed")

    def scrape(self, url: str, email: str) -> List[CompromisedData]:
        results = []
        try:
            with self._get_driver() as driver:
                driver.get(url)
                self.logger.info(f"Navigating to {url}")
                
                wait = WebDriverWait(driver, 30)

                try:
                    email_input = wait.until(
                        EC.visibility_of_element_located((By.XPATH, self.EMAIL_INPUT_XPATH))
                    )
                    self.logger.info("Email input field found.")
                    email_input.clear()
                    email_input.send_keys(email)
                    self.logger.info(f"Email entered: {email}")

                    search_button = driver.find_element(By.XPATH, self.SEARCH_BUTTON_XPATH)
                    search_button.click()
                    self.logger.info("Search button clicked.")
                except TimeoutException:
                    self.logger.error("Email input field not found within the wait time.")
                    return results
                except Exception as e:
                    self.logger.error(f"Error entering email: {e}")
                    return results

                try:
                    wait.until(EC.presence_of_all_elements_located((By.XPATH, self.RESULT_WRAPPER_XPATH)))
                    breach_wrappers = driver.find_elements(By.XPATH, self.RESULT_WRAPPER_XPATH)
                    self.logger.info(f"Found {len(breach_wrappers)} breach wrapper(s)")
                except TimeoutException:
                    self.logger.error("No results found")
                    return results
                except Exception as e:
                    self.logger.error(f"Error waiting for results: {e}")
                    return results

                for idx, wrapper in enumerate(breach_wrappers, start=1):
                    try:
                        breach_items = wrapper.find_elements(By.XPATH, './/div[@class="breach-item"]')
                        self.logger.info(f"Processing breach wrapper {idx} with {len(breach_items)} items")

                        current_data = {}
                        for item in breach_items:
                            try:
                                label_element = item.find_element(By.TAG_NAME, 'b')
                                label = label_element.text.strip(':').lower().replace(' ', '_').replace('originally_', '')
                                value = item.text.split(':', 1)[1].strip()
                                
                                if label == 'company_name' and current_data:
                                    data = CompromisedData(
                                        company_name=current_data.get('company_name', 'N/A'),
                                        domain_name=current_data.get('domain_name', 'N/A'),
                                        date_breach_occurred=current_data.get('date_breach_occurred', 'N/A'),
                                        info_breached=current_data.get('type_of_information_breached', 'N/A'),
                                        accounts_affected=current_data.get('total_number_of_accounts_affected', 'N/A'),
                                        breach_overview=current_data.get('breach_overview', 'N/A')
                                    )
                                    results.append(data)
                                    self.logger.info(f"Extracted breach: {data}")
                                    current_data = {}
                                
                                current_data[label] = value
                            except NoSuchElementException:
                                self.logger.info("Necessary sub-elements not found in a breach item")
                            except IndexError:
                                self.logger.info("No value found for the label in a breach item")
                            except Exception as e:
                                self.logger.error(f"Unexpected error processing breach item: {e}")
                                self.logger.error(traceback.format_exc())

                        if current_data:
                            data = CompromisedData(
                                company_name=current_data.get('company_name', 'N/A'),
                                domain_name=current_data.get('domain_name', 'N/A'),
                                date_breach_occurred=current_data.get('date_breach_occurred', 'N/A'),
                                info_breached=current_data.get('type_of_information_breached', 'N/A'),
                                accounts_affected=current_data.get('total_number_of_accounts_affected', 'N/A'),
                                breach_overview=current_data.get('breach_overview', 'N/A') 
                            )
                            results.append(data)
                            self.logger.info(f"Extracted breach: {data}")
                            
                    except Exception as e:
                        self.logger.error(f"Error extracting data from breach wrapper {idx}: {e}")
                        self.logger.error(traceback.format_exc())

                return results

        except Exception as e:
            self.logger.error(f"Error during scraping: {e}")
            self.logger.error(traceback.format_exc())
            return results