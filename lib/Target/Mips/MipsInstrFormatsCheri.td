//=-- MipsInstrFormatsCheri.td- CHERIiInstruction Formats ----*- tablegen -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// BC2F
class CheriFmtCBT<bits<5> op, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  MipsInst<outs, ins, asmstr, pattern, IIBranch, FrmOther>
{
  bits<5>  cb;
  bits<16> offset;

  let Opcode = 0x12;
  let Inst{25-21} = op;
  let Inst{20-16} = cb;
  let Inst{15-0} = offset;

  let isBranch = 1;
  let isTerminator = 1;
  let hasDelaySlot = 1;
}

class CheriFmtRegs<bits<5> op, bits<3> fmt, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  MipsInst<outs, ins, asmstr, pattern, NoItinerary, FrmOther> {
  bits<5> r0;
  bits<5> r1;
  bits<5> r2;


  let Opcode = 0x12;
  let Inst{25-21} = op;
  let Inst{20-16} = r0;
  let Inst{15-11} = r1;
  let Inst{10-6}  = r2;
  let Inst{5-3}  = 0; // Reserved
  let Inst{2-0}   = fmt;
}

// CGet*
class CheriFmtGet<bits<3> op, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  CheriFmtRegs<0x0, op, outs, ins, asmstr, pattern> {
  bits<5>  rd;
  bits<5>  cb;
  let r0 = rd;
  let r1 = cb;
  let r2 = 0;
}
class CheriFmtGetCause<bits<5> op, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  CheriFmtRegs<0, 4,outs, ins, asmstr, pattern> {
  bits<5>  rd;
  let r0 = rd;
  let r1 = 0;
  let r2 = 0;
}
class CheriFmtSetCause<bits<5> op, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  CheriFmtRegs<4, 4,outs, ins, asmstr, pattern> {
  bits<5>  rs;
  let r0 = 0;
  let r1 = 0;
  let r2 = rs;
}


// CSet*
class CheriFmtSet<bits<3> op, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  CheriFmtRegs<0x4, op, outs, ins, asmstr, pattern> {
  bits<5>  cd;
  bits<5>  cb;
  bits<5>  rt;
  let r0 = cd;
  let r1 = cb;
  let r2 = rt;
}

// 
class CheriFmt2Caps<bits<5> op, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  CheriFmtRegs<op, 0, outs, ins, asmstr, pattern> {
  bits<5>  cd;
  bits<5>  cs;
  let r0 = cd;
  let r1 = cs;
  let r2 = 0;
}

// CSealData, CUnseal
class CheriFmt3Caps<bits<5> op, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  CheriFmtRegs<op, 0, outs, ins, asmstr, pattern> {
  bits<5>  cd;
  bits<5>  cs;
  bits<5>  ct;
  let r0 = cd;
  let r1 = cs;
  let r2 = ct;
}

class CheriFmtPtrCmp<bits<3> cmp, RegisterOperand RC, string instr_asm,
                     list<dag> pattern>:
  CheriFmtRegs<0x0e, cmp, (outs RC: $rd), (ins CheriOpnd: $cb, CheriOpnd: $ct),
           !strconcat(instr_asm, "\t$rd, $cb, $ct"),
           pattern> {
  bits<5>  rd;
  bits<5>  cb;
  bits<5>  ct;
  let r0 = rd;
  let r1 = cb;
  let r2 = ct;
}

class CheriFmt3CCall<bits<5> op, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  CheriFmtRegs<op, 0, outs, ins, asmstr, pattern> {
  bits<5>  cs;
  bits<5>  cb;
  let r0 = cs;
  let r1 = cb;
  let r2 = 0;
}
class CheriFmt2CJMP<bits<5> op, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  CheriFmtRegs<op, 0, outs, ins, asmstr, pattern> {
  bits<5>  cs;
  bits<5>  rt;
  let r0 = 0;
  let r1 = cs;
  let r2 = rt;
}
class CheriFmt3CRet<bits<5> op, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  CheriFmtRegs<op, 0, outs, ins, asmstr, pattern> {
  let r0 = 0;
  let r1 = 0;
  let r2 = 0;
}

class CheriFmtClearTag<dag outs, dag ins, string asmstr,
                       list<dag> pattern> :
  CheriFmtSet<0x5, outs, ins, asmstr, pattern>
{
  let rt = 0;
}


// Load / Store capabilities
class CheriFmtCLS<bits<6> op, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  MipsInst<outs, ins, asmstr, pattern, NoItinerary, FrmOther>
{
  bits<5>  cs;
  bits<5>  cb;
  bits<5>  rt;
  bits<11> offset;

  let Opcode = op;
  let Inst{25-21} = cs;
  let Inst{20-16} = cb;
  let Inst{15-11} = rt;
  let Inst{10-0}  = offset;
}
class CheriFmtCSCR<dag outs, dag ins, string asmstr,
                   list<dag> pattern> :
  CheriFmtCLS<0x3e, outs, ins, asmstr, pattern>;
class CheriFmtCLCR<dag outs, dag ins, string asmstr,
                   list<dag> pattern> :
  CheriFmtCLS<0x36, outs, ins, asmstr, pattern>;

class CheriFmtCLX<bits<2> t, bits<1> e, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  MipsInst<outs, ins, asmstr, pattern, NoItinerary, FrmOther>
{
  bits<5>  rd;
  bits<5>  cb;
  bits<5>  rt;
  bits<8>  offset;

  let Opcode = 0x32;
  let Inst{25-21} = rd;
  let Inst{20-16} = cb;
  let Inst{15-11} = rt;
  let Inst{10-3}  = offset;
  let Inst{2}     = e;
  let Inst{1-0}   = t;
}

class CheriFmtCSX<bits<2> t, bits<1> e, dag outs, dag ins, string asmstr,
                list<dag> pattern> :
  MipsInst<outs, ins, asmstr, pattern, NoItinerary, FrmOther>
{
  bits<5>  rs;
  bits<5>  cb;
  bits<5>  rt;
  bits<8>  offset;

  let Opcode = 0x3a;
  let Inst{25-21} = rs;
  let Inst{20-16} = cb;
  let Inst{15-11} = rt;
  let Inst{10-3}  = offset;
  let Inst{2}     = e;
  let Inst{1-0}   = t;
}
