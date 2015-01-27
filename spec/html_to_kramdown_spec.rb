require 'rspec'
require 'pp'
require_relative '../lib//html_to_kramdown'


describe "just plain text" do
  it "should pass through unchanged" do
    expect(HTMLtoKramdown.new("hey there").to_kramdown).to eq "hey there"
  end

  it "should not mess with newlines" do
    expect(HTMLtoKramdown.new("hey there\nnow\n\nno new lines").to_kramdown).to eq "hey there\nnow\n\nno new lines"
  end
end

describe "general cleanup" do
  it "should reduce all runs of newlines down to two" do
    i = "<p>foo</p>\n\n<p>bar</p>\n\n\n<p>baz</p>"
    o = "foo\n\nbar\n\nbaz"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end
end

describe "paragraphs" do
  it "should remove paragraph markup and insert newlines on both sides" do
    expect(HTMLtoKramdown.new("<p>foo</p><p>bar</p>").to_kramdown).to match /foo\n\n+bar/
  end

  it "should keep paragraph attributes, if any" do
    expect(HTMLtoKramdown.new("<p class='bar'>foo</p>").to_kramdown).to eq "foo\n{: class='bar'}"
  end

  it "should catch multiple attributes" do
    i = "<p class='bar' id='u88' data-p=\"junk here\">foo</p>"
    o = "foo\n{: class='bar' id='u88' data-p='junk here'}"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end
end

describe "italic and emphasis" do
  it "should wrap italics in underscores" do
    i = "<p>foo <i>bar</i>\nand <i>this one\nis multiline</i></p>"
    o = "foo _bar_\nand _this one\nis multiline_"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end

  it "should capture attributes" do
    i = "<p>foo <i class=\"wow\">bar</i>\nand <i id='id9'>this one\nis multiline</i></p>"
    o = "foo _bar_{: class='wow'}\nand _this one\nis multiline_{: id='id9'}"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end

  it "should do the same for emphasis" do
    i = "<p>foo <em>bar</em>\nand <em>this one\nis multiline</em></p>"
    o = "foo _bar_\nand _this one\nis multiline_"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o

    i = "<p>foo <em class=\"wow\">bar</em>\nand <em id='id9'>this one\nis multiline</em></p>"
    o = "foo _bar_{: class='wow'}\nand _this one\nis multiline_{: id='id9'}"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end
end

describe "bold and strong" do
  it "should wrap bold in double asterisks" do
    i = "<p>foo <b>bar</b>\nand <b>this one\nis multiline</b></p>"
    o = "foo **bar**\nand **this one\nis multiline**"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end

  it "should capture attributes" do
    i = "<p>foo <b class=\"wow\">bar</b>\nand <b id='id9'>this one\nis multiline</b></p>"
    o = "foo **bar**{: class='wow'}\nand **this one\nis multiline**{: id='id9'}"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end

  it "should work for <strong> as well" do
    i = "<p>foo <strong class=\"wow\">bar</strong>\nand <strong id='id9'>this one\nis multiline</strong></p>"
    o = "foo **bar**{: class='wow'}\nand **this one\nis multiline**{: id='id9'}"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end
end

describe "images" do
  it "should capture the <img src=...> correctly" do
    i = "foo <img src='bar.jpg' /> baz"
    o = "foo ![](bar.jpg) baz"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end

  it "should capture the <img alt=...> correctly" do
    i = "foo <img src='bar.jpg' alt='hi there'/> baz"
    o = "foo ![hi there](bar.jpg) baz"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end

  it "should capture the <img title=...> correctly" do
    i = "foo <img src='bar.jpg' alt='hi there' title='a thing'/> baz"
    o = "foo ![hi there](bar.jpg 'a thing') baz"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end

  it "should capture all the other attributes kramdown style" do
    i = "foo <img src='bar.jpg' alt='hi there' title='a thing' width='77px' border='1px' style='quux' /> baz"
    o = "foo ![hi there](bar.jpg 'a thing'){: width='77px' border='1px' style='quux'} baz"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end
end

describe "headers" do
  it "should capture the h1 block with octothorpes" do
    i = "<h1>Foo bar</h1>"
    o = "# Foo bar"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end

  it "should capture other headers too" do
    i = "<h2>Foo</h2><h3>bar</h3><h4>baz</h4><h5>qux</h5><h6>quux</h6>"
    o = "## Foo\n\n### bar\n\n#### baz\n\n##### qux\n\n###### quux"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end

  it "should capture styles if any" do
    i = "<h1 class='filigree'>Foo bar</h1>"
    o = "# Foo bar\n{: class='filigree'}"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end

  it "should permit span markup within a header" do
    i = "<h1 class='filigree'>Foo <i>bar</i></h1>"
    o = "# Foo _bar_\n{: class='filigree'}"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end
end

describe "line breaks <br> and <br />" do
  it "should not affect the HTML except to put a newline in to clarify" do
    i = "Foo bar<br />baz"
    o = "Foo bar<br />\nbaz"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end

  it "should work for <br> or <br /> forms" do
    i = "Foo bar<br><br />baz"
    o = "Foo bar<br />\n<br />\nbaz"
    expect(HTMLtoKramdown.new(i).to_kramdown).to eq o
  end
end

describe "blockquotes" do
  it "should add newlines surrounding blockquotes"
  it "should preface every line of contents with '> ', even across paragraphs"
  it "should not have > marks outside the original blockquote range"
  it "should render interior content normally, and indent it ALL"
  it "should be nestable"
end