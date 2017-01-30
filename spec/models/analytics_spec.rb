require 'rails_helper'

describe Analytics do

  describe ".track" do

    it "should store a query" do
      Analytics.track(id: 1, query: 'how to', results_count: 10)

      Analytics.update_stats!
      stats = Analytics.stats_all
      
      expect(stats).to eq([["how to", 1.0]])
    end

    it "shouldn't double hit a query for a same user for while" do
      Analytics.track(id: 1, query: 'how to', results_count: 10)
      Analytics.update_stats!

      Analytics.track(id: 1, query: 'how to', results_count: 10)
      Analytics.update_stats!

      stats = Analytics.stats_all
      
      expect(stats).to eq([["how to", 1.0]])
    end

    it "allow double hit a query for a same user after a while" do
      Analytics.track(id: 1, query: 'how to', results_count: 10)
      Analytics.update_stats!

      user = Analytics::User.new(1)
      user.processed.clear

      Analytics.track(id: 1, query: 'how to', results_count: 10)
      Analytics.update_stats!

      stats = Analytics.stats_all
      
      expect(stats).to eq([["how to", 2.0]])
    end
  end
  
  describe '.update_stats!' do

    it "should build a sentence removing segments" do
        
      queries.each do |query|
          Analytics.track(id: 1, query: query, results_count: 10)
      end

      Analytics.update_stats!
      stats = Analytics.stats_all
      result = [
          ["what is my account number", 1.0], 
          ["how do i cancel my subscription", 1.0]
      ]

      expect(stats).to eq(result)
    end

    it "should remove segments already stored in stats" do
      
      queries.each do |query|
          Analytics.track(id: 1, query: query, results_count: 10)
          Analytics.update_stats!
      end

      stats = Analytics.stats_all
      result = [
          ["what is my account number", 1.0], 
          ["how do i cancel my subscription", 1.0]
      ]

      expect(stats).to match_array(result)
    end
  end

  describe '.stats_all' do

    it "should return ordered by the highest frequency" do
      # first user
      queries.each do |query|
          Analytics.track(id: 1, query: query, results_count: 10)
      end

      # second user
      Analytics.track(id: 2, query: "how do i cancel my subscription", results_count: 10)
      
      Analytics.update_stats!
      stats = Analytics.stats_all
      result = [
          ["how do i cancel my subscription", 2.0], 
          ["what is my account number", 1.0]
      ]

      expect(stats).to eq(result)
    end
  end

  describe '.clear_stats!' do

    it "should return ordered by the highest frequency" do
      # first user
      queries.each do |query|
          Analytics.track(id: 1, query: query, results_count: 10)
      end

      # second user
      Analytics.track(id: 2, query: "how do i cancel my subscription", results_count: 10)
      
      Analytics.update_stats!
      Analytics.clear_stats!
      stats = Analytics.stats_all
      
      expect(stats).to eq([])
    end

  end

  private
  
  def queries
    [
      "How do I cancel my subscription",
      "How do I",
      "How do",
      "What is my account number",
      "What i"
    ]
  end
end
