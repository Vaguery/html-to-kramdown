# html-to-kramdown
Light-handed gem to convert HTML syntax to [kramdown (1.x)](http://kramdown.gettalong.org) syntax, more or less reversibly

## status

Very early in the process. Not suitable for primetime. Also: not a gem, yet.

## goals

- Should not modify HTML code wraped in `code` blocks
- Should handle nesting in `blockquote` and list nodes
- Should prserve all inline styles, classes and other attributes, either by leaving styled tags alone or "kramdownifying" the syntax
- Should permit toggling of processing on a tag-by-tag basis (_e.g._, 
  if the original document uses `em` for emphasis and `i` for Latin abbreviations or book titles, you should be able to
  retain the `i` tags while converting the `em` tags to kramdown)
