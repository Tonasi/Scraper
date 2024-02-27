# frozen_string_literal: true

class ScraperController < ApplicationController
  def data
    scraped_data = scrape_data(params[:url], params[:fields])

    render json: scraped_data
  end

  private

  # Need to confirm the captcha within 10 seconds
  def scrape_data(url, fields)
    driver = Selenium::WebDriver.for :chrome
    driver.navigate.to url
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    result = {}

    fields.each do |field_name, key|
      result[field_name] = if fields.include?('meta')
                             meta_data(wait, key, driver)
                           else
                             wait.until { driver.find_element(css: key) }.text
                           end
    end

    driver.quit
    result
  end

  def meta_data(wait, meta_keys, driver)
    meta_keys.each_with_object({}) do |id, hash|
      field = wait.until { driver.find_element(css: "meta[name='#{id}'], meta[id='#{id}']") }
      hash[id] = field.attribute('content')
    end
  end
end
