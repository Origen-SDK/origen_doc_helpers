require 'spec_helper'

describe "The GuideIndex API" do

  it "is alive" do
    index = OrigenDocHelpers::GuideIndex.new
    index.section nil do |section|
      section.page :intro, heading: "Introduction"
      section.page :page2, heading: "Page 2"
      end
    index.section :topic1, heading: "Topic 1" do |section|
      section.page :item1, heading: "First Item"
      section.page :item2, heading: "Second Item"
    end

    index.to_h.should == {
      nil       => { :intro => "Introduction",
                     :page2 => "Page 2"
                   },
      "Topic 1" => { :topic1_item1 => "First Item",
                     :topic1_item2 => "Second Item"
                   }
    }
  end

  it "allows sections to be inserted" do
    index = OrigenDocHelpers::GuideIndex.new
    index.section nil do |section|
      section.page :intro, heading: "Introduction"
      section.page :page2, heading: "Page 2"
      end
    index.section :topic1, heading: "Topic 1" do |section|
      section.page :item1, heading: "First Item"
      section.page :item2, heading: "Second Item"
    end

    index.section :topic0, heading: "Topic 0", before: :topic1 do |section|
      section.page :mytopic
    end

    index.section :topic0a, heading: "Topic 0a", after: :topic0 do |section|
      section.page :mytopic
    end

    index.to_h.should == {
      nil        => { :intro => "Introduction",
                     :page2 => "Page 2"
                    },
      "Topic 0"  => { :topic0_mytopic => "mytopic"
                    },
      "Topic 0a" => { :topic0a_mytopic => "mytopic"
                    },
      "Topic 1"  => { :topic1_item1 => "First Item",
                      :topic1_item2 => "Second Item"
                    }
    }
  end

  it "allows pages to be inserted" do
    index = OrigenDocHelpers::GuideIndex.new
    index.section nil do |section|
      section.page :intro, heading: "Introduction"
      section.page :page2, heading: "Page 2"
      end
    index.section :topic1, heading: "Topic 1" do |section|
      section.page :item1, heading: "First Item"
      section.page :item2, heading: "Second Item"
    end

    index.section :topic1 do |section|
      section.page :mypage, heading: "My Page", after: :item1
    end

    index.section :topic1 do |section|
      section.page :mypage0, heading: "My Page 0", before: :mypage
    end

    index.to_h.should == {
      nil       => { :intro => "Introduction",
                     :page2 => "Page 2"
                   },
      "Topic 1" => { :topic1_item1   => "First Item",
                     :topic1_mypage0 => "My Page 0",
                     :topic1_mypage  => "My Page",
                     :topic1_item2   => "Second Item"
                   }
    }
  end

  it "allows sections to be inserted in any order" do
    index = OrigenDocHelpers::GuideIndex.new

    # Test that this can be added with a reference to topic0, even though that
    # section does not exist yet
    index.section :topic0a, heading: "Topic 0a", after: :topic0 do |section|
      section.page :mytopic
    end

    index.section :topic0, heading: "Topic 0", before: :topic1 do |section|
      section.page :mytopic
    end

    index.section nil do |section|
      section.page :intro, heading: "Introduction"
      section.page :page2, heading: "Page 2"
      end
    index.section :topic1, heading: "Topic 1" do |section|
      section.page :item1, heading: "First Item"
      section.page :item2, heading: "Second Item"
    end

    index.to_h.should == {
      nil        => { :intro => "Introduction",
                     :page2 => "Page 2"
                    },
      "Topic 0"  => { :topic0_mytopic => "mytopic"
                    },
      "Topic 0a" => { :topic0a_mytopic => "mytopic"
                    },
      "Topic 1"  => { :topic1_item1 => "First Item",
                      :topic1_item2 => "Second Item"
                    }
    }
  end

  it "allows pages to be inserted in any order" do
    index = OrigenDocHelpers::GuideIndex.new

    index.section :topic1 do |section|
      section.page :mypage0, heading: "My Page 0", before: :mypage
    end

    index.section :topic1 do |section|
      section.page :mypage, heading: "My Page", after: :item1
    end

    index.section nil do |section|
      section.page :intro, heading: "Introduction"
      section.page :page2, heading: "Page 2"
      end
    index.section :topic1, heading: "Topic 1" do |section|
      section.page :item1, heading: "First Item"
      section.page :item2, heading: "Second Item"
    end

    index.to_h.should == {
      nil       => { :intro => "Introduction",
                     :page2 => "Page 2"
                   },
      "Topic 1" => { :topic1_item1   => "First Item",
                     :topic1_mypage0 => "My Page 0",
                     :topic1_mypage  => "My Page",
                     :topic1_item2   => "Second Item"
                   }
    }
  end

  it 'pending sections can be forced' do
    index = OrigenDocHelpers::GuideIndex.new

    index.section :topic1, heading: "Topic 1" do |section|
      section.page :item1, heading: "First Item"
      section.page :item2, heading: "Second Item"
    end

    index.section :topic0a, heading: "Topic 0a", after: :topic0 do |section|
      section.page :mytopic
    end

    index.section :topic1 do |section|
      section.page :mypage0, heading: "My Page 0", before: :mypage
    end

    index.to_h.should == {
      "Topic 1" => { :topic1_item1   => "First Item",
                     :topic1_item2   => "Second Item"
                   }
    }

    index.force_pending.to_h.should == {
      "Topic 1"  => { :topic1_item1   => "First Item",
                      :topic1_item2   => "Second Item",
                      :topic1_mypage0 => "My Page 0"
                    },
      "Topic 0a" => { :topic0a_mytopic => "mytopic"
                    }
    }
  end

end
