
I/O PORTS : http://stanislavs.org/helppc/ports.html

http://www.nasm.us/pub/nasm/releasebuilds/2.12.02/win32/nasm-2.12.02-win32.zip

nasm boot\boot.asm
nasm boot\setup.asm 

kernel ����ѡ��ѡ x64

WDK7.1 ml64 Kernel\regs.asm������regs.obj�� Kernel Ŀ¼��

�ر�GS����: ��Ŀ����->C/C++->��������->��������ȫ��飨��
��������Ĭ�Ͽ�: ��Ŀ����->������->����->��������Ĭ�Ͽ⣨�ǣ�
�޸���ڵ�:     ��Ŀ����->������->�߼�->��ڵ㣨�����Զ��庯������ Init��
�޸�image��ַ:  ��Ŀ����->������->�߼�->��ַ��0xffff800000000000��
�̶���ַ:       ��Ŀ����->������->�߼�->�̶���ַ��/FIXED��
�ϲ����ݶ�:     ��Ŀ����->������->�߼�->�ϲ�����.rdata=.data��
//�ϲ����ݶ�:     #pragma comment(linker, "/MERGE:.rdata=.data")
//ȥ��������Ϣ:   ��Ŀ����->������->����->���ɵ�����Ϣ����

Ƕ����:
ml64 xxx.asm
��xxx.obj ����������Ŀ¼�£����ӵ�  ��Ŀ����->������->����->����������

Debug�棺
��Ŀ����->��������ʱ��飨Ĭ��ֵ��