/* ----------------------------------------------------------------- */
/*           The Toolkit for Building Voice Interaction Systems      */
/*           "MMDAgent" developed by MMDAgent Project Team           */
/*           http://www.mmdagent.jp/                                 */
/* ----------------------------------------------------------------- */
/*                                                                   */
/*  Copyright (c) 2009-2013  Nagoya Institute of Technology          */
/*                           Department of Computer Science          */
/*                                                                   */
/* All rights reserved.                                              */
/*                                                                   */
/* Redistribution and use in source and binary forms, with or        */
/* without modification, are permitted provided that the following   */
/* conditions are met:                                               */
/*                                                                   */
/* - Redistributions of source code must retain the above copyright  */
/*   notice, this list of conditions and the following disclaimer.   */
/* - Redistributions in binary form must reproduce the above         */
/*   copyright notice, this list of conditions and the following     */
/*   disclaimer in the documentation and/or other materials provided */
/*   with the distribution.                                          */
/* - Neither the name of the MMDAgent project team nor the names of  */
/*   its contributors may be used to endorse or promote products     */
/*   derived from this software without specific prior written       */
/*   permission.                                                     */
/*                                                                   */
/* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND            */
/* CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,       */
/* INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF          */
/* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE          */
/* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS */
/* BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,          */
/* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED   */
/* TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,     */
/* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON */
/* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,   */
/* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    */
/* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE           */
/* POSSIBILITY OF SUCH DAMAGE.                                       */
/* ----------------------------------------------------------------- */

/* headers */

#include "MMDAgent.h"
#include "MMDFiles.h"

/* PMDModel::renderModel: render the model */
/* needs multi-texture function on OpenGL: */
/* texture unit 0: model texture */
/* texture unit 1: toon texture for toon shading */
/* texture unit 2: additional sphere map texture, if exist */
void PMDModel::renderModel(const float *lightDirection)
{
    renderModel2(lightDirection);
}

/* PMDModel::renderForShadow: render for shadow */
void PMDModel::renderForShadow()
{
    renderForShadow2();
}

/* PMDModel::renderForPick: render for pick */
void PMDModel::renderForPick()
{
    renderForPick2();
}

/* PMDModel::renderDebug: render for debug view */
void PMDModel::renderDebug()
{
    renderDebug2();
}

/* PMDModel::renderModel: render the model */
/* needs multi-texture function on OpenGL: */
/* texture unit 0: model texture */
/* texture unit 1: toon texture for toon shading */
/* texture unit 2: additional sphere map texture, if exist */
void PMDModel::renderModel2(const float* lightDirection)
{
    unsigned int i;
    float c[4];
    PMDMaterial *m;
    float modelAlpha;
    unsigned int numSurface;
    unsigned int surfaceOffset;
    bool drawEdge;
    
    //NSLog(@"xxx PMDModel::renderModel");
    
    if (!m_vertexList) return;
    if (!m_showFlag) return;
    
    GLuint program = m_mmdagent->shaders()[0]._program;
    
    glUseProgram(program);
    
    //NSLog(@"xxx PMDModel::renderModel 002");
    
    // Feed Projection and Model View matrices to the shaders
    PVRTMat4 mVP = m_mmdagent->getMatProjection() * m_mmdagent->getMatView();
    
    /* update light direction vector */
    m_light = btVector3(btScalar(lightDirection[0]), btScalar(lightDirection[1]), btScalar(lightDirection[2]));
    m_light.normalize();
    
    glUniformMatrix4fv(glGetUniformLocation(program, "modelViewProjectionMatrix"), 1, GL_FALSE, mVP.ptr());
    //glUniformMatrix4fv(glGetUniformLocation(program, "lightViewProjectionMatrix"), 1, GL_FALSE, mVP.ptr());
    
#ifndef MMDFILES_CONVERTCOORDINATESYSTEM
    //glPushMatrix();
    //glScalef(1.0f, 1.0f, -1.0f); /* from left-hand to right-hand */
    //glCullFace(GL_FRONT);
    
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */

    //ES2
    glEnable(GL_CULL_FACE);

    glBindBuffer(GL_ARRAY_BUFFER, m_vboBufStatic);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_vboBufElement);
    
    glVertexAttribPointer(ATTRIB_TEXCOORD,
                          2, GL_FLOAT, GL_FALSE, sizeof(TexCoord), (const GLvoid *) NULL);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    
    glBindBuffer(GL_ARRAY_BUFFER, m_vboBufDynamic);
    
    /* set lists */
    glVertexAttribPointer(ATTRIB_POSITION,
                          3, GL_FLOAT, GL_FALSE, sizeof(btVector3), (const GLvoid *) m_vboOffsetVertex);
    glEnableVertexAttribArray(ATTRIB_POSITION);
    
    glVertexAttribPointer(ATTRIB_NORMAL,
                          3, GL_FLOAT, GL_FALSE, sizeof(btVector3), (const GLvoid *) m_vboOffsetNormal);
    glEnableVertexAttribArray(ATTRIB_NORMAL);
    
    glUniform3f(glGetUniformLocation(program, "lightDirection"), m_light[0], m_light[1], m_light[2]);
    
    //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_vboBufElement);
    
    //State
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //ES2
    glCullFace(GL_CCW);
    //glCullFace(GL_CW);

    /* activate texture unit 0 */
    glActiveTexture(GL_TEXTURE0);

#if 1
    
    if (m_toon) {
        // set toon texture coordinates to texture unit 1
        //glActiveTextureARB(GL_TEXTURE1_ARB);
        glActiveTexture(GL_TEXTURE1);
        //glEnable(GL_TEXTURE_2D);
        //glClientActiveTextureARB(GL_TEXTURE1_ARB);
        //glClientActiveTexture(GL_TEXTURE1);
        //glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glEnableVertexAttribArray(ATTRIB_TEXCOORD);
        
        if (m_selfShadowDrawing) {
            // probably this section is wrong
            glBindBuffer(GL_ARRAY_BUFFER, m_vboBufStatic);
            //glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid *) m_vboOffsetCoordForShadowMap);
            glVertexAttribPointer(glGetUniformLocation(program, "inTexCoord"),
                                  2, GL_FLOAT, GL_FALSE, sizeof(TexCoord), (const GLvoid *) m_vboOffsetCoordForShadowMap);
            glEnableVertexAttribArray(glGetUniformLocation(program, "inTexCoord"));
            glBindBuffer(GL_ARRAY_BUFFER, m_vboBufDynamic);
        } else {
            glVertexAttribPointer(glGetUniformLocation(program, "inTexCoord"),
                                  2, GL_FLOAT, GL_FALSE, sizeof(TexCoord), (const GLvoid *) m_vboOffsetToon);
            glEnableVertexAttribArray(glGetUniformLocation(program, "inTexCoord"));
            
        }
        
        //glEnableVertexAttribArray(glGetUniformLocation(program, "inTexCoord"));
        
        //glActiveTextureARB(GL_TEXTURE0_ARB);
        //glClientActiveTextureARB(GL_TEXTURE0_ARB);
        glActiveTexture(GL_TEXTURE0);
        //glClientActiveTexture(GL_TEXTURE0);
        
    }
    
    
    if (m_hasSingleSphereMap) {
        /* this model contains single sphere map texture */
        /* set texture coordinate generation for sphere map on texture unit 0 */
        //glEnable(GL_TEXTURE_2D);
        //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        //glDisable(GL_TEXTURE_2D);
    }
    if (m_hasMultipleSphereMap) {
        /* this model contains additional sphere map texture */
        /* set texture coordinate generation for sphere map on texture unit 2 */
        //glActiveTextureARB(GL_TEXTURE2_ARB);
        //glActiveTexture(GL_TEXTURE2);
        //glEnable(GL_TEXTURE_2D);
        //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        //glDisable(GL_TEXTURE_2D);
        //glActiveTextureARB(GL_TEXTURE0_ARB);
        //glActiveTexture(GL_TEXTURE0);
    }
    
#endif
    
    /* calculate alpha value, applying model global alpha */
    modelAlpha = m_globalAlpha;
    
    /* render per material */
    for (i = 0; i < m_numMaterial; i++) {
        
        glUniform1f(glGetUniformLocation(program, "opacity"), modelAlpha);
        
        glUniform1i(glGetUniformLocation(program, "useToon"), 0);
        glUniform1i(glGetUniformLocation(program, "useSoftShadow"), 0);
        glUniform1i(glGetUniformLocation(program, "hasSubTexture"), 0);
        glUniform1i(glGetUniformLocation(program, "hasDepthTexture"), 0);
        glUniform1i(glGetUniformLocation(program, "isMainAdditive"), 0);
        glUniform1i(glGetUniformLocation(program, "isSubAdditive"), 0);
        glUniform1i(glGetUniformLocation(program, "hasMainTexture"), 0);
        
        glUniform1i(glGetUniformLocation(program, "isMainSphereMap"), 0);
        glUniform1i(glGetUniformLocation(program, "isSubSphereMap"), 0);
        
        m = &(m_material[m_materialRenderOrder[i]]);
        /* set colors */
        c[3] = m->getAlpha() * modelAlpha;
        if (c[3] > 0.99f) c[3] = 1.0f; /* clamp to 1.0 */
        /* use each color */
        m->copyDiffuse(c);
        c[3] = c[3] * m->getAlpha();
        if (c[3] > 0.99f) c[3] = 1.0f; /* clamp to 1.0 */
        glUniform4f(glGetUniformLocation(program, "materialColor"), c[0], c[1], c[2], c[3]);
        //m->copyAmbient(c);
        //glUniform4f(glGetUniformLocation(program, "materialShininess"), c[0], c[1], c[2], c[3]);
        m->copySpecular(c);
        if (c[3] > 0.99f) c[3] = 1.0f; /* clamp to 1.0 */
        glUniform3f(glGetUniformLocation(program, "materialSpecular"), c[0], c[1], c[2]);
        
        glUniform1f(glGetUniformLocation(program, "materialShininess"), m->getShiness());
        //glUniform1f(glGetUniformLocation(program, "opacity"), 1.0f);
        
#if 1
        
        /* disable face culling for transparent materials */
        // ES2
        if (m->getAlpha() < 1.0f)
            glDisable(GL_CULL_FACE);
        else
            glEnable(GL_CULL_FACE);

        /* if using multiple texture units, set current unit to 0 */
        if (m_toon || m_hasMultipleSphereMap) {
            glActiveTexture(GL_TEXTURE0);
        }
        
        //ES2
        glCullFace(GL_BACK);
        
#endif
  
        glActiveTexture(GL_TEXTURE0);
        
        if (m->getTexture()) {
            /* bind model texture */
            //glEnable(GL_TEXTURE_2D);
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, m->getTexture()->getID());
            /* set GL_CLAMP_TO_EDGE for toon texture to avoid texture interpolation at edge */
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            glUniform1i(glGetUniformLocation(program, "hasMainTexture"), 1);
            glUniform1i(glGetUniformLocation(program, "mainTexture"), 0);
            
            if (m_hasSingleSphereMap) {
                if (m->getTexture()->isSphereMap()) {
                    /* this is sphere map */
                    /* enable texture coordinate generation */
                    if (m->getTexture()->isSphereMapAdd()) {
                        glUniform1i(glGetUniformLocation(program, "isMainAdditive"), 1);
                    } else {
                        glUniform1i(glGetUniformLocation(program, "isMainAdditive"), 0);
                        
                    }
                }
            } else {
                
            }
            
        } else {
            //glDisable(GL_TEXTURE_2D);
            glUniform1i(glGetUniformLocation(program, "hasMainTexture"), 0);
        }
        
        if (m_toon) {
            /* set toon texture for texture unit 1 */
            glActiveTexture(GL_TEXTURE1);
            //glEnable(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D, m_toonTextureID[m->getToonID()]);
            /* set GL_CLAMP_TO_EDGE for toon texture to avoid texture interpolation at edge */
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            glUniform1i(glGetUniformLocation(program, "toonTexture"), 1);
            glUniform1i(glGetUniformLocation(program, "useToon"), 1);
            
        } else {
            glActiveTexture(GL_TEXTURE0);
            glUniform1i(glGetUniformLocation(program, "toonTexture"), 0);
            glUniform1i(glGetUniformLocation(program, "useToon"), 0);
        }
        
        if (m_hasMultipleSphereMap) {
            if (m->getAdditionalTexture()) {
                /* this material has additional sphere map texture, bind it at texture unit 2 */
                glActiveTexture(GL_TEXTURE2);
                glBindTexture(GL_TEXTURE_2D, m->getAdditionalTexture()->getID());
                //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                
                glUniform1i(glGetUniformLocation(program, "subTexture"), 2);
                glUniform1i(glGetUniformLocation(program, "hasSubTexture"), 1);
                
                if (m->getAdditionalTexture()->isSphereMapAdd()) {
                    glUniform1i(glGetUniformLocation(program, "isSubAdditive"), 1);
                } else {
                    glUniform1i(glGetUniformLocation(program, "isSubAdditive"), 0);
                }
                
                
            } else {
                /* disable generation */
                glActiveTexture(GL_TEXTURE0);
                //glDisable(GL_TEXTURE_2D);
                glUniform1i(glGetUniformLocation(program, "hasSubTexture"), 0);
            }
        }
        
        /* draw elements */
        glDrawElements(GL_TRIANGLES, m->getNumSurface(), GL_UNSIGNED_SHORT,
                       (const GLvoid *) (sizeof(unsigned short) * m->getSurfaceListIndex()));
        
        /* reset some parameters */
        if (m->getTexture() && m->getTexture()->isSphereMap() && m->getTexture()->isSphereMapAdd()) {
            if (m_toon) {
                glActiveTexture(GL_TEXTURE0);
            }
        }
        
    }
    
    //glDisableClientState(GL_NORMAL_ARRAY);
    //glDisableVertexAttribArray(ATTRIB_NORMAL);
    
#if 0
    
    if (m_toon) {
        //glClientActiveTextureARB(GL_TEXTURE0_ARB);
        //glClientActiveTexture(GL_TEXTURE0);
        //glActiveTexture(GL_TEXTURE0);
        //glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        //glDisableVertexAttribArray(ATTRIB_TEXCOORD);
        
        if (m_hasSingleSphereMap) {
            //glActiveTextureARB(GL_TEXTURE0_ARB);
            //glActiveTexture(GL_TEXTURE0);
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
        }
        
        //glClientActiveTextureARB(GL_TEXTURE1_ARB);
        //glClientActiveTexture(GL_TEXTURE1);
        //glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        //glActiveTexture(GL_TEXTURE1);
        //glDisableVertexAttribArray(ATTRIB_TEXCOORD);
        
        
        if (m_hasMultipleSphereMap) {
            //glActiveTextureARB(GL_TEXTURE2_ARB);
            //glActiveTexture(GL_TEXTURE2);
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
        }
        
        //glActiveTextureARB(GL_TEXTURE0_ARB);
        //glActiveTexture(GL_TEXTURE0);
    } else {
        //glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        //glDisableVertexAttribArray(ATTRIB_TEXCOORD);
        
        if (m_hasSingleSphereMap) {
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
        }
        if (m_hasMultipleSphereMap) {
            //glActiveTextureARB(GL_TEXTURE2_ARB);
            //glActiveTexture(GL_TEXTURE2);
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
            //glActiveTextureARB(GL_TEXTURE0_ARB);
            //glActiveTexture(GL_TEXTURE0);
        }
        
    }
    
    if (m_hasSingleSphereMap || m_hasMultipleSphereMap) {
        //glDisable(GL_TEXTURE_GEN_S);
        //glDisable(GL_TEXTURE_GEN_T);
    }
    
    if (m_toon) {
        //glActiveTextureARB(GL_TEXTURE1_ARB);
        //glActiveTexture(GL_TEXTURE1);
        //glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        //glDisableVertexAttribArray(ATTRIB_TEXCOORD);
        
    }
    
    if (m_hasMultipleSphereMap) {
        //glActiveTexture(GL_TEXTURE2);
        //glDisable(GL_TEXTURE_2D);
    }
    
#endif
    
    glActiveTexture(GL_TEXTURE0);
    
    //glDisable(GL_TEXTURE_2D);
    //ES2
    glEnable(GL_CULL_FACE);
    
#ifndef MMDFILES_CONVERTCOORDINATESYSTEM
    
    //ES2 glCullFace(GL_BACK);
    
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */

    //ES2 glCullFace(GL_BACK);
    
    /* draw edge */
    drawEdge = true;
    if (m_forceEdge) {
        /* force edge drawing even if this model has no edge surface or no-toon mode */
        if (m_numSurfaceForEdge == 0) {
            numSurface = m_numSurface;
            surfaceOffset = 0;
        } else {
            numSurface = m_numSurfaceForEdge;
            surfaceOffset = m_vboOffsetSurfaceForEdge;
        }
    } else {
        /* draw edge when toon mode, skip when this model has no edge surface */
        if (!m_toon) drawEdge = false;
        if (m_numSurfaceForEdge == 0) drawEdge = false;
        numSurface = m_numSurfaceForEdge;
        surfaceOffset = m_vboOffsetSurfaceForEdge;
    }
    
    if (drawEdge) {
        
#ifdef MMDFILES_CONVERTCOORDINATESYSTEM
        //glPushMatrix();
        //glScalef(1.0f, 1.0f, -1.0f);
        //ES2
        glCullFace(GL_BACK);
#else
        /* draw back surface only */
        //ES2
        glCullFace(GL_FRONT);
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */

        //glDisable(GL_LIGHTING);
        //glColor4f(m_edgeColor[0], m_edgeColor[1], m_edgeColor[2], m_edgeColor[3] * modelAlpha);
        glVertexAttribPointer(ATTRIB_POSITION,
                              3, GL_FLOAT, GL_FALSE, sizeof(btVector3), (const GLvoid *) m_vboOffsetEdge);
        glEnableVertexAttribArray(ATTRIB_POSITION);
        glDrawElements(GL_TRIANGLES, numSurface, GL_UNSIGNED_SHORT, (const GLvoid *) surfaceOffset);
        //glEnable(GL_LIGHTING);
        
        /* draw front again */
#ifdef MMDFILES_CONVERTCOORDINATESYSTEM
        //ES2
        glCullFace(GL_FRONT);
#else
        //ES2
        glCullFace(GL_BACK);
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */

    }
    
}

/* PMDModel::renderForShadow: render for shadow */
void PMDModel::renderForShadow2()
{
    
    // disabled function for debug
    //return;
    
   if (!m_vertexList) return;
   if (!m_showFlag) return;

   /* plain drawing of only edge surfaces */
   if (m_numSurfaceForEdge == 0) return;

    GLuint program = m_mmdagent->shaders()[1]._program;
    glUseProgram(program);

   //ES2
    glDisable(GL_CULL_FACE);

    // Feed Projection and Model View matrices to the shaders
    PVRTMat4 mVP = m_mmdagent->getMatProjection() * m_mmdagent->getMatView();
    m_shadowColor[0] = 0.0f;
    m_shadowColor[1] = 0.50f;
    m_shadowColor[2] = 0.50f;

    glUniform3f(glGetUniformLocation(program, "lightColor"), m_shadowColor[0], m_shadowColor[1], m_shadowColor[2]);
    
    glUniformMatrix4fv(glGetUniformLocation(program, "modelViewProjectionMatrix"), 1, GL_FALSE, mVP.ptr());

    glBindBuffer(GL_ARRAY_BUFFER, m_vboBufStatic);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_vboBufElement);
    glBindBuffer(GL_ARRAY_BUFFER, m_vboBufDynamic);

    //glVertexAttribPointer(ATTRIB_POSITION,
    //                      3, GL_FLOAT, GL_FALSE, sizeof(btVector3), (const GLvoid *) m_vboOffsetVertex);
    glVertexAttribPointer(ATTRIB_POSITION,
                          3, GL_FLOAT, GL_FALSE, sizeof(btVector3), (const GLvoid *) m_vboOffsetEdge);
    glEnableVertexAttribArray(ATTRIB_POSITION);
   
    glDrawElements(GL_TRIANGLES, m_numSurfaceForEdge, GL_UNSIGNED_SHORT, (const GLvoid *) m_vboOffsetSurfaceForEdge);
   
    //glDisableClientState(GL_VERTEX_ARRAY);
   
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
   //ES2
    glEnable(GL_CULL_FACE);
}

/* PMDModel::renderForPick: render for pick */
void PMDModel::renderForPick2()
{
   unsigned int j;
   btVector3 *vertexList;
   btVector3 v1, v2;

   if (!m_vertexList) return;
   if (!m_showFlag) return;

   /* prepare vertex */
   vertexList = new btVector3[m_numVertex];
   for (j = 0; j < m_numVertex; j++) {
      if (m_boneWeight1[j] >= 1.0f - PMDMODEL_MINBONEWEIGHT) {
         /* bone 1 */
         vertexList[j] = m_boneSkinningTrans[m_bone1List[j]] * m_vertexList[j];
      } else if (m_boneWeight1[j] <= PMDMODEL_MINBONEWEIGHT) {
         /* bone 2 */
         vertexList[j] = m_boneSkinningTrans[m_bone2List[j]] * m_vertexList[j];
      } else {
         /* lerp */
         v1 = m_boneSkinningTrans[m_bone1List[j]] * m_vertexList[j];
         v2 = m_boneSkinningTrans[m_bone2List[j]] * m_vertexList[j];
         vertexList[j] = v2.lerp(v1, btScalar(m_boneWeight1[j]));
      }
   }

   /* plain drawing of all surfaces without VBO */
   //ES2 glDisable(GL_CULL_FACE);

    glVertexAttribPointer(ATTRIB_POSITION,
                          3, GL_FLOAT, GL_FALSE, sizeof(btVector3), (const GLvoid *) vertexList);
    glEnableVertexAttribArray(ATTRIB_POSITION);
   glDrawElements(GL_TRIANGLES, m_numSurface, GL_UNSIGNED_SHORT, m_surfaceList);
    
   //ES2 glEnable(GL_CULL_FACE);

   delete [] vertexList;
}

/* PMDModel::renderDebug: render for debug view */
void PMDModel::renderDebug2()
{
   unsigned short i;

   if (!m_vertexList) return;

   glDisable(GL_DEPTH_TEST);

   /* draw bones */
   for (i = 0; i < m_numBone; i++)
      m_boneList[i].renderDebug();

   glEnable(GL_DEPTH_TEST);
}
