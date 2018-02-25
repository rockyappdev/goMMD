/* ----------------------------------------------------------------- */
/* ----------------------------------------------------------------- */
/*                                                                   */
/*  Copyright (c) 2009-2013  XXXXXXX          */
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

#define VMD_INTERPOLATIONTABLESIZE 64 /* motion interpolation table size */

@class ScenarioData;


/* VMD: motion file class */
class MotionVMD
{
private:

   unsigned int m_numTotalBoneKeyFrame;   /* total number of bone frames */
   unsigned int m_numTotalFaceKeyFrame;   /* total number of face frames */
   unsigned int m_numTotalCameraKeyFrame; /* total number of camera frames */
   unsigned int m_numTotalSwitchKeyFrame; /* total number of model switch frames */

   PTree m_name2bone;
   PTree m_name2face;

   BoneMotionLink *m_boneLink;   /* linked list of bones in the motion */
   FaceMotionLink *m_faceLink;   /* linked list of faces in the motion */
   CameraMotion *m_cameraMotion; /* list of camera key frame data */
   SwitchMotion *m_switchMotion; /* list of model switch key frame data */

   unsigned int m_numBoneKind; /* number of bones in m_boneLink */
   unsigned int m_numFaceKind; /* number of faces in m_faceLink */

   float m_maxFrame; /* max frame */

   /* addBoneMotion: add new bone motion to list */
   void addBoneMotion(const char *name);

   /* addFaceMotion: add new face motion to list */
   void addFaceMotion(const char *name);

   /* getBoneMotion: find bone motion by name */
   BoneMotion * getBoneMotion(const char *name);

   /* getFaceMotion: find face motion by name */
   FaceMotion * getFaceMotion(const char *name);

   /* setBoneInterpolationTable: set up bone motion interpolation parameter */
   void setBoneInterpolationTable(BoneKeyFrame *bf, const char *ip);

   /* setCameraInterpolationTable: set up camera motion interpolation parameter */
   void setCameraInterpolationTable(CameraKeyFrame *cf, const char *ip);

   /* initialize: initialize VMD */
   void initialize();

   /* clear: free VMD */
   void clear();

public:

   /* VMD: constructor */
   MotionVMD();

   /* ~VMD: destructor */
   ~MotionVMD();

   /* load: initialize and load from file name */
   bool load(ScenarioData *_scenarioData);

   /* parse: initialize and load from data memories */
   bool parse(const unsigned char *data, unsigned long size);

   /* getTotalKeyFrame: get total number of key frames */
   unsigned int getTotalKeyFrame();

   /* getBoneMotionLink: get list of bone motions */
   BoneMotionLink * getBoneMotionLink();

   /* getFaceMotionLink: get list of face motions */
   FaceMotionLink * getFaceMotionLink();

   /* getCameraMotion: get camera motion */
   CameraMotion *getCameraMotion();

   /* getSwitchMotion: get model switch motion */
   SwitchMotion *getSwitchMotion();

   /* getNumBoneKind: get number of bone motions */
   unsigned int getNumBoneKind();

   /* getNumFaceKind: get number of face motions */
   unsigned int getNumFaceKind();

   /* getMaxFrame: get max frame */
   float getMaxFrame();
};
