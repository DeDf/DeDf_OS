
I/O PORTS : http://stanislavs.org/helppc/ports.html

http://www.nasm.us/pub/nasm/releasebuilds/2.12.02/win32/nasm-2.12.02-win32.zip

nasm boot\boot.asm
nasm boot\setup.asm 

kernel ����ѡ��ѡ x64

�ر�GS����: ��Ŀ����->C/C++->��������->��������ȫ��飨��
��������Ĭ�Ͽ�: ��Ŀ����->������->����->��������Ĭ�Ͽ⣨�ǣ�
�޸���ڵ�:     ��Ŀ����->������->�߼�->��ڵ㣨�����Զ��庯������ main��
�޸�image��ַ:  ��Ŀ����->������->�߼�->��ַ��0xffff800000000000��
�̶���ַ:       ��Ŀ����->������->�߼�->�̶���ַ��/FIXED��
�ϲ����ݶ�:     ��Ŀ����->������->�߼�->�ϲ�����.rdata=.data��
//�ϲ����ݶ�:     #pragma comment(linker, "/MERGE:.rdata=.data")
//ȥ��������Ϣ:   ��Ŀ����->������->����->���ɵ�����Ϣ����

Ƕ����:
�Ҽ���Ŀ->���->xxx.asm�ļ�
�Ҽ�xxx.asm������
�Զ������ɲ���->����:
  ������(ml64 /c xxx.asm)
  ���(xxx.obj)

Debug�棺
��Ŀ����->��������ʱ��飨Ĭ��ֵ��

dedf_os.img ��winhex�༭�Ļ�����Ҫȥ��img��׺����

bochsdbg.exe->DeDf_OS.bxrc,
�������
�ϵ㣺b 0x7c00
���У�c
���룺s
������p
����trace-reg on, ��ִ�е������Ե�ʱ�򶼻���ʾ�Ĵ����ĵ�ǰ״̬��.
