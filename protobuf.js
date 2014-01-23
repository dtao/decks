hljs.registerLanguage('protobuf', function(hljs) {
  return {
    keywords: {
      keyword: 'message optional required repeated',
      literal: 'int32 int64 string boolean'
    },
    defaultMode: {
      contains: [
        hljs.QUOTE_STRING_MODE,
        hljs.NUMBER_MODE
      ]
    }
  };
});
