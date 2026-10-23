-- Hospital staff registers the donation process for the donor they are attending
CREATE POLICY "staff create donations" ON public.donations FOR INSERT TO authenticated
WITH CHECK (public.has_role(auth.uid(), 'hospital_staff') OR public.has_role(auth.uid(), 'admin'));