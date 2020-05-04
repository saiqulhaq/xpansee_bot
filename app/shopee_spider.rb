require 'kimurai'

class ShopeeSpider < Kimurai::Base
  @name = "shopee_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://shopee.co.id/Pashmina-ceruti-BABY-DOLL-heavy-chiffon-i.8802990.1243172697"]
  @config = {
    user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36",
    before_request: { delay: 2..4 }
  }

  def parse(response, url:, data: {})
    item = {
      title: browser.find(:xpath, '//*[@id="main"]/div/div[2]/div[2]/div[2]/div[2]/div[3]/div/div[1]/span').text.squish,
      description: browser.find(:xpath, '//*[@id="main"]/div/div[2]/div[2]/div[2]/div[3]/div[2]/div[1]/div[1]/div[2]/div[2]/div').text.squish,
    }
    variants_xpath = '//*[@id="main"]/div/div[2]/div[2]/div[2]/div[2]/div[3]/div/div[4]/div/div[2]/div/div[1]/div'
    item[:variants] = []
    response.xpath(variants_xpath).children.each_with_index do |child, index|
      next if child.attribute('class').value.include?('disabled')

      browser.find(:xpath, variants_xpath + "/button[#{index + 1}]").click

      sleep 1.5

      price = if browser.has_xpath? '//*[@id="main"]/div/div[2]/div[2]/div[2]/div[2]/div[3]/div/div[3]/div/div/div[1]/div/div[1]'
                browser.find :xpath, '//*[@id="main"]/div/div[2]/div[2]/div[2]/div[2]/div[3]/div/div[3]/div/div/div[1]/div/div[1]'
              else
                browser.find :xpath, '//*[@id="main"]/div/div[2]/div[2]/div[2]/div[2]/div[3]/div/div[3]/div/div/div/div/div/div'
              end

      item[:variants].push({
        name: child.text.squish,
        stock: browser.find(:xpath, '//*[@id="main"]/div/div[2]/div[2]/div[2]/div[2]/div[3]/div/div[4]/div/div[2]/div/div[2]/div[2]/div[2]').text.squish.match('\w\s(\d*)\s\w').try(:[], 1).to_i,
        price: price.text.squish,
      })
    end
    item
  end
end
