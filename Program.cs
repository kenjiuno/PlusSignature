using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Web;
using System.Collections.Specialized;
using Microsoft.Win32;
using System.Diagnostics;

namespace PlusSignature {
    class Program {
        static void Main(string[] args) {
            String fpexe = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "wlmail.exe");
            String more = "";
            foreach (String a in args) {
                if (a.StartsWith("/mailurl:")) {
                    UriBuilder b = new UriBuilder(a.Substring(9));
                    Encoding e = Encoding.Default;
                    NameValueCollection nvc = HttpUtility.ParseQueryString(b.Query.TrimStart('?'), e);
                    List<string> keys = new List<string>();
                    List<string> vals = new List<string>();
                    for (int x = 0; x < nvc.Count; x++) {
                        keys.Add(nvc.GetKey(x));
                        vals.Add(nvc.Get(x));
                    }
                    for (int x = 0; x < keys.Count; x++) {
                        if (keys[x] == "body") {
                            String mySig = "";
                            RegistryKey rkSig = Registry.CurrentUser.OpenSubKey(@"Software\Microsoft\Windows Live Mail\signatures", false);
                            if (rkSig != null) {
                                String DefaultSignature = "" + rkSig.GetValue("Default Signature");
                                if (DefaultSignature.Length != 0) {
                                    RegistryKey rkDS = rkSig.OpenSubKey(DefaultSignature, false);
                                    if (rkDS != null) {
                                        String type = "" + rkDS.GetValue("type");
                                        if (type == "1") {
                                            mySig = "" + rkDS.GetValue("text");
                                        }
                                        else if (type == "2") {
                                            String fpin = "" + rkDS.GetValue("file");
                                            if (File.Exists(fpin)) mySig = File.ReadAllText(fpin, Encoding.Default);
                                        }
                                    }
                                }
                            }

                            vals[x] += "\r\n\r\n" + mySig;
                        }
                    }
                    StringWriter wr = new StringWriter();
                    for (int x = 0; x < keys.Count; x++) {
                        if (x != 0)
                            wr.Write("&");
                        wr.Write("{0}={1}", HttpUtility.UrlEncode(keys[x], e), HttpUtility.UrlEncode(vals[x], e));
                    }
                    b.Query = "" + wr;
                    b.Port = -1;
                    more += " /mailurl:" + b + "";
                }
                else {
                    more += " \"" + a + "\"";
                }
            }
            //Console.WriteLine(String.Join(" ", Environment.GetCommandLineArgs()));
            //Console.WriteLine();
            //Console.WriteLine(more);
            Process.Start(fpexe, more);
            //Console.ReadLine();
        }
    }
}
