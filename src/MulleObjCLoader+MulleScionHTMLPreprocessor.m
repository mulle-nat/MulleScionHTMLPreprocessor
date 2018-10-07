#import "import.h"

#ifdef __MULLE_OBJC__

@implementation MulleObjCLoader( MulleScionHTMLPreprocessor)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
#include "objc-loader.inc"

      { MULLE_OBJC_NO_CLASSID, MULLE_OBJC_NO_CATEGORYID }
   };

   return( dependencies);
}

@end

#endif

