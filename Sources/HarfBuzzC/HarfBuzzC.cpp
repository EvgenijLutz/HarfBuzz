//
//  HarfBuzzC.cpp
//  HarfBuzzFramework
//
//  Created by Evgenij Lutz on 04.08.25.
//

// NOTE: FreeType support was removed

//#include <HarfBuzzC.hpp>
//#include <hb-ft.h>
//#include <FreeTypeC/libfreetype.h>
//
//void testHarfBuzzC(const char* __nonnull path) {
//    FT_Library library;
//    if (FT_Init_FreeType(&library)) {
//        printf("Could not init FreeType library\n");
//        return;
//    }
//    printf("FreeType library created successfully\n");
//    
//    FT_Face face;
//    if (FT_New_Face(library, path, 0, &face)) {
//        printf("Could not load FreeType face\n");
//        return;
//    }
//    printf("FreeType face created successfully\n");
//    
//    auto hbFace = hb_ft_face_create(face, nullptr);
//    if (hbFace == nullptr) {
//        printf("Could not create HarfBuzz face\n");
//        FT_Done_Face(face);
//        FT_Done_FreeType(library);
//        return;
//    }
//    printf("HarfBuzz face created successfully\n");
//    
//    hb_face_destroy(hbFace);
//    
//    FT_Done_Face(face);
//    
//    
//    FT_Done_FreeType(library);
//}
