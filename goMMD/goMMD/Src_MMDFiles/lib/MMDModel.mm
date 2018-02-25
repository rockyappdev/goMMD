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

#import  "ScenarioData.h"
#include "MMDAgent.h"

/* PMDModel::initialize: initialize PMDModel */
void MMDModel::initialize()
{
   int i;

   m_name = "";
   m_comment = "";

   m_numVertex = 0;
   m_vertexList = NULL;
   m_normalList = NULL;
   m_texCoordList = NULL;
   m_bone1List = NULL;
   m_bone2List = NULL;
   m_boneWeight1 = NULL;
   m_noEdgeFlag = NULL;

   m_numSurface = 0;
   m_surfaceList = NULL;

   m_numMaterial = 0;
   m_material = NULL;

   m_numBone = 0;
   m_boneList = NULL;

   m_numIK = 0;
   m_IKList = NULL;

   m_numFace = 0;
   m_faceList = NULL;

   m_numRigidBody = 0;
   m_rigidBodyList = NULL;

   m_numConstraint = 0;
   m_constraintList = NULL;

   for(i = 0; i < SYSTEMTEXTURE_NUMFILES; i++) {
      m_toonTextureID[i] = 0;
      m_localToonTexture[i].release();
   }

   m_boneSkinningTrans = NULL;
   m_numSurfaceForEdge = 0;
   m_vboBufDynamic = 0;
   m_vboBufStatic = 0;
   m_vboBufElement = 0;
   m_vboBufDynamicLen = 0;
   m_vboOffsetVertex = 0;
   m_vboOffsetNormal = 0;
   m_vboOffsetToon = 0;
   m_vboOffsetEdge = 0;
   m_vboOffsetSurfaceForEdge = 0;
   m_vboOffsetCoordForShadowMap = 0;

   m_centerBone = NULL;
   m_baseFace = NULL;
   m_orderedBoneList = NULL;
   m_hasSingleSphereMap = false;
   m_hasMultipleSphereMap = false;
   m_numRotateBone = 0;
   m_rotateBoneIDList = NULL;
   m_IKSimulated = NULL;
   m_enableSimulation = true;
   m_maxHeight = 0.0f;
   m_boundingSphereStep = PMDMODEL_BOUNDINGSPHEREPOINTSMIN;
   m_materialRenderOrder = NULL;
   m_materialDistance = NULL;

   /* initial values for variables that should be kept at model change */
   m_toon = false;
   m_light.setZero();
   m_globalAlpha = 1.0f;
   m_edgeOffset = 0.03f;
   m_selfShadowDrawing = false;
   m_selfShadowDensityCoef = 0.0f;
   m_edgeColor[0] = PMDMODEL_EDGECOLORR;
   m_edgeColor[1] = PMDMODEL_EDGECOLORG;
   m_edgeColor[2] = PMDMODEL_EDGECOLORB;
   m_edgeColor[3] = PMDMODEL_EDGECOLORA;
   m_forceEdge = false;

    m_usePhysicsSimuration = false;
   m_bulletPhysics = NULL;
   m_rootBone.reset();

   m_showFlag = true;

    m_mmdagent = NULL;

}

/* PMDModel::clear: free PMDModel */
void MMDModel::clear()
{
   int i;

   if (m_vertexList)
      delete [] m_vertexList;
   if (m_normalList)
      delete [] m_normalList;
   if (m_texCoordList)
      free(m_texCoordList);
   if (m_bone1List)
      free(m_bone1List);
   if (m_bone2List)
      free(m_bone2List);
   if (m_boneWeight1)
      free(m_boneWeight1);
   if (m_noEdgeFlag)
      free(m_noEdgeFlag);
   if (m_surfaceList)
      free(m_surfaceList);
   if (m_material)
      delete [] m_material;
   m_textureLoader.release();
   if (m_boneList)
      delete [] m_boneList;
   if (m_IKList)
      delete [] m_IKList;
   if (m_faceList)
      delete [] m_faceList;
   if (m_constraintList)
      delete [] m_constraintList;
   if (m_rigidBodyList)
      delete [] m_rigidBodyList;

   if (m_boneSkinningTrans)
      delete [] m_boneSkinningTrans;
   if (m_vboBufDynamic != 0)
      glDeleteBuffers(1, &m_vboBufDynamic);
   if (m_vboBufStatic != 0)
      glDeleteBuffers(1, &m_vboBufStatic);
   if (m_vboBufElement != 0)
      glDeleteBuffers(1, &m_vboBufElement);
   if (m_orderedBoneList)
      free(m_orderedBoneList);
   if (m_rotateBoneIDList)
      free(m_rotateBoneIDList);
   if (m_IKSimulated)
      free(m_IKSimulated);

   if (m_materialRenderOrder)
      free(m_materialRenderOrder);
   if (m_materialDistance)
      free(m_materialDistance);

   for (i = 0; i < SYSTEMTEXTURE_NUMFILES; i++)
      m_localToonTexture[i].release();
   m_name2bone.release();
   m_name2face.release();

   initialize();
}

/* MMDModel::MMDModel: constructor */
MMDModel::MMDModel(MMDAgent *mmdagent)
{
    initialize();
    m_mmdagent = mmdagent;
}

/* PMDModel::~PMDModel: destructor */
MMDModel::~MMDModel()
{
   clear();
}

void MMDModel::setTextureLib(int ival)
{
    m_textureLib = ival;
}

int MMDModel::getTextureLib()
{
    return m_textureLib;
}

/* PMDModel::load: load from file name */
bool MMDModel::load( ScenarioData *_scenarioData, void *_bullet, void *_systex)
{
    size_t size;
    unsigned char *data;
    bool ret;

    NSLog(@"... MMDModel::load entered");
    
    NSLog(@"... MModel::load m_textureLib=[%d]", m_textureLib);
    
    if (_systex == NULL) {
        NSLog(@"*** MMDModel::load failed _systex is NULL");
        return false;
        
    }
    if (_scenarioData == NULL) {
        NSLog(@"*** MMDModel::load failed scenarioData is NULL");
        return false;
    }
    
    BulletPhysics *bullet = (BulletPhysics*)_bullet;
    SystemTexture *systex = (SystemTexture*)_systex;
    ScenarioData *scenarioData = _scenarioData;
    
    if (![scenarioData openCurrentModelZipPath]) {
        NSLog(@"*** Error: MMDModel::load Failed to open Zip file");
        return false;
    }
    
    NSData *nsData = [scenarioData readZipCurrentModelPath];
    
	if( nsData == nil )
    {
        [scenarioData closeZipFile];
        NSLog(@"*** MMDModel::load Failed to read Zip file model data");
        return false;
    }
	
    data = (unsigned char*)[nsData bytes];
    if (!data)
    {
        [scenarioData closeZipFile];
        NSLog(@"*** MMDModel::load Failed to create binary data from Zip file");
        return false;
    }
    
    size = (unsigned long)[nsData length];

   /* initialize and load from the data memories */
    NSLog(@"... MDModel::load parsing the MMDModel data");
    
    /* initialize and load from the data memories */
    NSLog(@"... MDModel::load parsing the PMDModel data");
    
    ret = parse(data, (unsigned long) size, bullet, systex, _scenarioData);
    
   return ret;
}

/* PMDModel::setPhysicsControl switch bone control by physics simulation */
void MMDModel::setPhysicsControl(bool flag)
{
   unsigned long i;
   unsigned short j;

    if (!m_usePhysicsSimuration) return;

   if (flag == m_enableSimulation) return;

   m_enableSimulation = flag;
   /* when true, align all rigid bodies to corresponding bone by setting Kinematics flag */
   /* when false, all rigid bodies will have their own motion states according to the model definition */
   for (i = 0; i < m_numRigidBody; i++)
      m_rigidBodyList[i].setKinematic(!flag);

   if (flag == false) {
      /* save the current bone transform with no physics as a start transform for later resuming */
      //updateBone();
      for (j = 0; j < m_numBone; j++)
         m_boneList[j].saveTrans();
   }
}

/* MMDModel::release: free PMDModel */
void MMDModel::release()
{
   clear();
}

void MMDModel::setUsePhysicsSimulation(bool flag)
{
    m_usePhysicsSimuration = flag;
}

bool MMDModel::usePhysicsSimulation( void )
{
    return m_usePhysicsSimuration;
}

/* MMDModel::setShowFlag: set show flag */
void MMDModel::setShowFlag(bool flag)
{
   m_showFlag = flag;
}

/* MMDModel:;setEdgeThin: set edge offset */
void MMDModel::setEdgeThin(float thin)
{
   m_edgeOffset = thin * 0.03f;
}

/* PMDModel:;setToonFlag: set toon rendering flag */
void MMDModel::setToonFlag(bool flag)
{
   m_toon = flag;
}

/* PMDModel::getToonFlag: return true when enable toon rendering */
bool MMDModel::getToonFlag()
{
   return m_toon;
}

/* PMDModel::setSelfShadowDrawing: set self shadow drawing flag */
void MMDModel::setSelfShadowDrawing(bool flag)
{
   m_selfShadowDrawing = flag;
}

/* PMDModel::setEdgeColor: set edge color */
void MMDModel::setEdgeColor(float *color)
{
   int i;

   if(color == NULL)
      return;
   for(i = 0; i < 4; i++)
      m_edgeColor[i] = color[i];
}

/* PMDModel::setGlobalAlpha: set global alpha value */
void MMDModel::setGlobalAlpha(float alpha)
{
   m_globalAlpha = alpha;
}

/* PMDModel::getRootBone: get root bone */
PMDBone *MMDModel::getRootBone()
{
   return &m_rootBone;
}

/* PMDModel::getCenterBone: get center bone */
PMDBone *MMDModel::getCenterBone()
{
   return m_centerBone;
}

/* PMDModel::getName: get name */
const char *MMDModel::getName()
{
    return m_name.c_str();
}

/* PMDModel::getNumVertex: get number of vertics */
unsigned int MMDModel::getNumVertex()
{
   return m_numVertex;
}

/* PMDModel::getNumSurface: get number of surface definitions */
unsigned int MMDModel::getNumSurface()
{
   return m_numSurface;
}

/* PMDModel::getNumMaterial: get number of material definitions */
unsigned int MMDModel::getNumMaterial()
{
   return m_numMaterial;
}

/* PMDModel::getNumBone: get number of bones */
unsigned short MMDModel::getNumBone()
{
   return m_numBone;
}

/* PMDModel::getNumIK: get number of IK chains */
unsigned short MMDModel::getNumIK()
{
   return m_numIK;
}

/* PMDModel::getNumFace: get number of faces */
unsigned short MMDModel::getNumFace()
{
   return m_numFace;
}

/* PMDModel::getNumRigidBody: get number of rigid bodies */
unsigned int MMDModel::getNumRigidBody()
{
   return m_numRigidBody;
}

/* PMDModel::getNumConstraint: get number of constraints */
unsigned int MMDModel::getNumConstraint()
{
   return m_numConstraint;
}

/* PMDModel::getErrorTextureList: get error texture list */
void MMDModel::getErrorTextureList(char *buf, int size)
{
   m_textureLoader.getErrorTextureString(buf, size);
}

/* PMDModel::getMaxHeight: get max height */
float MMDModel::getMaxHeight()
{
   return m_maxHeight;
}

/* PMDModel::getComment: get comment of PMD */
const char *MMDModel::getComment()
{
   return m_comment.c_str();
}

/* PMDModel::setForceEdgeFlag: set force edge flag */
void MMDModel::setForceEdgeFlag(bool flag)
{
   m_forceEdge = flag;
}

