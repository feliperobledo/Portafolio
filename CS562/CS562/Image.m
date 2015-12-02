//
//  Image.m
//  HelloOpenGL
//
//  Created by Felipe Robledo on 10/30/14.
//  Copyright (c) 2014 Felipe Robledo. All rights reserved.
//

#import "Image.h"

@implementation Image

-(id)init
{
    if(self = [super init])
    {
    }
    
    return self;
}

//statics
+(Image*)Load:(NSString*)path
{
    if([path isEqualToString:@""])
    {
        NSLog(@"path to texture is nil");
        return nil;
    }
    
    Image* newImage = [[Image alloc]init];
    if(newImage == nil)
    {
        NSLog(@"Memory failure when creating a new Image instance");
        return nil;
    }
    
    //create the path to the .tga resource
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:path
                                                          ofType:@".tga"];
    
    //read in the .tga file into a temporary byte buffer
    NSData* tgaData = [NSData dataWithContentsOfFile:imagePath];
    if(tgaData == nil)
    {
        NSLog(@"TGA file %@ not found\n",imagePath);
        return nil;
    }
    
    NSUInteger fileLength = [tgaData length];
    unsigned char* fileBytes = (unsigned char*)[tgaData bytes];
    
    if([newImage loadTGA:fileBytes Size:fileLength] == YES)
    {
        return newImage;
    }
    
    return nil;
}

+(void)Free:(Image*)image
{
    free([image Data]);
}

-(GLuint)textureID
{
    return m_ID;
}

-(void)setTextureID:(GLuint)newID
{
    m_ID = newID;
    
    //Don't know what this means
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    //Bind the new texture ID to the target type we want
    glBindTexture(GL_TEXTURE_2D, newID);
    
    //Depending on the bits-per-pixel, we use a different format for the texture
    if(m_BPP == 32)
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)m_SizeX, (GLsizei)m_SizeY, 0, GL_RGBA, GL_UNSIGNED_BYTE, m_Data);
    }
    else
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei)m_SizeX, (GLsizei)m_SizeY, 0, GL_RGB, GL_UNSIGNED_BYTE, m_Data);
    }
    
    //Make the texture wrap around
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
//    glTexParameter
    //Now use the image data loaded into RAM
    //QUESTION: can I remove the texture from RAM once I give it to GL? YES
    //[Image Free:self];
}

-(void)sendTexture:(GLenum)texture
{
    //Set the current texture unit for the next bind texture method
    glActiveTexture(texture);
    
    //Bind the texture to the one we want to use
    glBindTexture(GL_TEXTURE_2D, m_ID);
}

-(unsigned char*) Data
{
    return m_Data;
}

-(signed long) BPP
{
    return m_BPP;
}

-(GLint) SizeX
{
    return m_SizeX;
}

-(GLint) SizeY
{
    return m_SizeY;
}

//private helper methods
-(BOOL) loadTGA:(unsigned char*)data Size:(signed long)dataSize
{
    if(data == NULL && dataSize == 0)
    {
        return NO;
    }
    
    //get the image type
    u8 imageType = data[2];
    if(imageType == 2)
    {
        NSLog(@"Only support uncompressed, true-color image");

    }
    
    //get the bits per pixel
    m_BPP = data[16];
    if(m_BPP == 24 || m_BPP == 32)
    {
        NSLog(@"Only support 24 or 32 bits image");
    }
    
    //get the image size
    m_SizeX = (data[13] << 8) | data[12];
    m_SizeY = (data[15] << 8) | data[14];
    
    //get the pointer to the image data area
    // * 18 is the header size
    // * the '0' entry is the number of bytes in the image id field (ignored!)
    u8* pImageData = data + 18 + data[0];
    
    // allocate memory for the data
    m_Data = malloc(sizeof(u8) * (m_SizeX * m_SizeY * m_BPP / 8));
    if(m_Data == 0)
    {
        NSLog(@"Problem allocating memory for .tga file");
        return NO;
    }
    
    // get the image descriptor to get the orientation
    // * bit 5 (0 = bottom, 1 = top)
    // * bit 4 (0 = left    1 = right)
    u8  desc    = data[17];
    u32 rowSize = m_SizeX * m_BPP / 8;
    
    // check if need to mirror the image vertically
    if ((desc & 0x20) == 0)
    {
        // mirror data upside down
        for (s32 y = 0; y < m_SizeY; ++y)
        {
            u32* pSrc = (u32*)(pImageData + y * rowSize);
            u32* pDst = (u32*)(m_Data + (m_SizeY - 1 - y) * rowSize);
            
            memcpy(pDst, pSrc, rowSize);
        }
    }
    else
    {
        memcpy(m_Data, pImageData, m_SizeY * rowSize);
    }
    
    // check if need to mirror the image horizontally
    if (desc & 0x10)
    {
        for (s32 y = 0; y < m_SizeY; ++y)
        {
            for (s32 x = 0; x < m_SizeX / 2; ++x)
            {
                u8* pSrc = data + y * rowSize + x * m_BPP / 8;
                u8* pDst = data + y * rowSize + (m_SizeX - 1 - x) * m_BPP / 8;
                
                pSrc[0] ^= pDst[0]; pDst[0] ^= pSrc[0]; pSrc[0] ^= pDst[0];
                pSrc[1] ^= pDst[1]; pDst[1] ^= pSrc[1]; pSrc[1] ^= pDst[1];
                pSrc[2] ^= pDst[2]; pDst[2] ^= pSrc[2]; pSrc[2] ^= pDst[2];
                
                if (m_BPP == 32)
                    pSrc[3] ^= pDst[3]; pDst[3] ^= pSrc[3]; pSrc[3] ^= pDst[3];
            }
        }
    }

    return YES;
}

@end
