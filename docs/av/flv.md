# FLV文件格式简介

一、FLV
    FLV是一种能很好适应网络流媒体的网络视频格式。相对于其它视频文件格，具有的视频质量良好、结构简单、占有率低和体积小等特点很适合网络传输。

1.1、FLV文件格式
    FLV文件格式结构比较简单，可以分为Header和Body两部分，Body又由一个个Tag和Tag Length组成。相惜结构如下图，注意第1个Tag length一般取0。
```txt
	|flv header| tag length| tag |tag length| tag |...|

```

1.2、FLV Header
FLV头部结构也很简单，字段如下

                Signature：FLV

                Version：版本

                V：1 – 包含视频流， 0 – 不包含视频流

                A：1 – 包含音频流， 0 – 不包含音频流

1.3、FLV Body
    FLV Body重点是由FLV Tag组成，而FLV Tag Length只是用32bit（UI32）来记录前一个Tag的长度总体长度。FLV Tag的整体结构是统一的，其结构划分如下：


                Type： 8- audio， 9- video， 18(0x12)- script data

                Data Size： Data字段的长度，单位是bit

                Timestamp： 时间戳，一般用于DTS

                Ext Timestamp： 溢出时间戳，当Timestamp溢出后才有意义

                StreamID： 流ID，对于一个FLV文件，总会设置为0

                Data： Tag所承载的音视频流数据


二、AVC/AAC下的FLV Tag结构
    上面给出了FLV的基本结构，其格式比较统一。因为FLV Tag内部承载的数据有多种类型，所以在FLV 的Data字段内还可以划分不同的子结构。下面结合实际介绍AAC音频和H264视频下的FLV Tag的详细结构。


2.1、FLV Video Tag — AVC
    可将FLV Video Tag划分为Tag Header和 Video Data两部分，其中Video Data即为FLV的Data字段。而Video Data又可分为Video Header和Video Packet。AVC中叫AVC Video Packet。

2.1.1、Video Header
    VIDEO HEADER长度为1个字节，其结构是：

	| FrameType(4) | CodecID(4) |
```txt
FrameType(FT)  = 1 : Key Frame (for AVC, a seekable frame)

						= 2 : Inter Frame (for AVC, a non-seekable frame)

						= 3 : disposable inter frame (H.263 only)

						= 4 : generated keyframe (reserved for server use only)

						= 5 : video info/command frame

CodecID(CID)    = 1 : JPEG (currently unused)

						= 2 : Sorenson H.263

						= 3 : Screen video

						= 4 : On2 VP6

						= 5 : On2 VP6 with alpha channel

						= 6 : Screen video version 2

						= 7 : H264/AVC
```
2.1.2、AVC Video Packet
    AVC Video Packet又可以分为AVC VIDEO Header和 Data两部分，其AVC VIDEO Header的结构如下：

| AVCPacketType(8)| CompostionTime(24) |
```txt
AVC package type(AVC PT)= 00 ：AVC Sequence Header，Data为AVC Decorder Configuration Record；

								= 01 ：AVC NALU，Data为NALUs；

								= 02 : AVC end of sequence，Data为空。

composition time    = 00 : 只有AVC package type =0时；

								= num: 为相对时间，即CTS，PTS = DTS + CTS*90。
```
因为AVC PT主要涉及前两种类型，下面分别介绍关键帧中其结构。

1、AVC Sequence Header

在 ISO/IEC 14496-15 中定义，FLV文件中第一个VIDEOTAG的VIDEODATA的AVC VIDEO PACKET的Data总是 AVC Decoder Configuration Record。一般位于流的第一个Tag中。

todo少一幅结构图
```txt

	CV:configurationVersion

	PI:AVCProfileIndication

	PC:profile_compatibility

	LI:AVCLevelIndication

	L:lengthSizeMinusOne，重要，视频中NALU的长度，计算方法1 + (L& 3)

	NSPS:numOfSequenceParameterSets，SPS的个数，计算方法是 NSPS&0x1F

	SPSL:sequenceParameterSetLength，SPS的长度。

	SPSNU:sequenceParameterSetNALUnit,SPSNU的长=8bit* SPSL

	NPPS:numOfPictureParameterSets, PPS 的个数

	PPSL:pictureParameterSetLength，PPS 的长度

	PPSNU:pictureParameterSetNALUnit,PPSNU的长=8bit* PPSL
```
2、AVC NALU

该类型下，Data部分承载的即为H264的NALU数据了，一个Video Tag可能包含多个NALU，为了区分和定位，FLV中采用NALU Length来确定NALU的长度。一个完整的关键帧的Tag的也可以表示如下图（对于其他非关键帧其结构类似，只是FT的值不一样），其中红色部分即为Data字段内容。

在H264中，每个NALU单元开头第一个byte的低5bits表示着该单元的类型（nal_unit_type）。所以每个NALU第一个byte & 0x1f 就可以得出它的类型:
```
                    nal_unit_type:

                                #define NALU_TYPE_SLICE 1  一个非IDR图像的编码条带

                                #define NALU_TYPE_DPA   2  编码条带数据分割块A

                                #define NALU_TYPE_DPB   3  编码条带数据分割块B

                                #define NALU_TYPE_DPC   4  编码条带数据分割块C

                                #define NALU_TYPE_IDR   5  IDR图像的编码条带

                                #define NALU_TYPE_SEI   6      辅助增强信息 (SEI)

                                #define NALU_TYPE_SPS   7  序列参数集

                                #define NALU_TYPE_PPS   8  图像参数集

                                #define NALU_TYPE_AUD   9  访问单元分隔符

                                #define NALU_TYPE_EOSEQ 10  序列结尾

                                #define NALU_TYPE_EOSTREAM  11 流结尾

                                #define NALU_TYPE_FILL      12 填充数据

                    例如：  0x67 & 0x1f = 7，则此单元是SPS

                                0x68 & 0x1f = 8，则此单元是PPS

        此处注意，在FLV中NALUs的结构是  |NALU长度|NALU| NALU长度|NALU|…

                        在H264中NALUs的结构是 |0000 0001|NALU|0000 0001|NALU|…
```
2.2、FLV Audio Tag — AAC
    可将FLV Audio Tag划分为Tag Header和 Audio Data两部分，其中Audio Data即为FLV的Data字段。可分为Audio Header和Audio Packet。AAC中叫AAC AudioPacket。

2.2.1、Audio Header
VIDEO HEADER的长度为1个字节，其结构是：

|SoundFormat(4) | SoundRate(2) |SoundSize(1)|SoundType(1)|
```txt
            SoundFormat(SF) = 0 : Linear PCM, platform endian

                                        = 1 : ADPCM

                                        = 2 : MP3

                                        = 3 : Linear PCM, little endian

                                        = 4 : Nellymoser 16 kHz mono

                                        = 5 : Nellymoser 8 kHz mono

                                        = 6 : Nellymoser

                                        = 7 : G.711 A-law logarithmic PCM

                                        = 8 : G.711 mu-law logarithmic PCM

                                        = 9 : reserved

                                        = 10 : AAC

                                        = 11 : Speex

                                        = 14 : MP3 8 kHz

                                        = 15 : Device-specific sound

            SoundRate(R)      = 0 : 5.5 kHz

                                        = 1 : 11 kHz

                                        = 2 : 22 kHz

                                        = 3 : 44 kHz

            SoundSize(S)       = 0 : 8-bit samples

                                        = 1 : 16-bit samples

            SoundType(T)      = 0 : Mono sound

                                        = 1 : Stereo sound
```
2.2.2、AAC Audio Packet
    如果SoundFormat不是10(AAC)，则Audio Packet的数据即为audio payload。但是AAC Audio Packet有两种不同的类型，标准中利用 AACPacketType来区分：

            AACPacketType(AACPType) = 0 : AAC sequence header

									= 1 : AAC raw

1、AAC sequence header

在FLV的文件中，一般情况下这种包只出现1次，而且是第一个audio tag。此时Data部分是2字节的Audio Specific Config，其结构如下：
```txt

            AAC Profile(ACCP) = 0x01 : AAC Main

                                        = 0x02 : AAC LC

                                        = 0x03 : AAC SSR

                                        = ……

            AACS: 采样率       = 0x00:96000, 0x01:88200, 0x02:64000, 0x03:48000,

                                        = 0x04:44100, 0x05:32000, 0x06:24000, … …

            AACC: 声道数       = 0x01:单声道, 0x02:双声道, 0x03:三声道, ……

            R: 保留字段
```
2、AAC raw

AAC raw数据很简单，在AACP Type后面紧跟的就是Audio Payload(音频有效载荷))数据，也就是ES流。整个结构如下：

数据播放时，一般的AAC解码器都需要把AAC的ES流打包成ADTS的格式，一般是在AAC ES流前添加7个字节的ADTS header。如下图所示：

    其中ADST头部结构如下：

            Syncword：为同步字段，其目的是用于定位帧头部在比特流中的位置。

            ID：用于区分标准，0表示MPEG-4, 1表示MPEG-2。

            Lay：即Layer，规定这两位为00。

            PA：即protection_absent，如果没有CRC则置为1，否则置为0。

            Pf：即Profile。规格对应为：0对应Main、1对应LC、2对应SSR，而3是保留的。

            SFI：即sampling frequency index。常见的采样率对应为：2对应64000Hz、3对应48000Hz、4对应44100Hz、5对应32000 Hz。

            CC：即channel conflguration。常见声道对应的为：1为单声道、2为双声道。

            PB为private bit、OC为original/copy、HO为Home、CIB为Copyright identification bit、CIS为Copyright identification start，这5个字段在当进行编码时设置为0，解码时则会被忽略。

            aac frame len：表示该数据帧的长度。其值必须包含ADTS头的长度，单位是字节。

            adts buffer fullness：通常置为0x7ff。

            N：表示ADTS中所包含的RDBs（AACframe）数目，通常情况下为一个。

            CRC：即Cyclic Redundancy Check，循环冗余校验。当protection_absent为0时才存在。






转载 https://blog.evanxia.com/2017/07/1378
